resource "aws_kms_key" "px_key" {
  description = "Key used to encrypt Portworx PVCs"
}

resource "null_resource" "create_workspace" {
  provisioner "local-exec" {
    command = <<EOF
test -e ${local.installer_workspace} || mkdir -p ${local.installer_workspace}
EOF
  }
}

resource "local_file" "portworx_operator_yaml" {
  content  = data.template_file.portworx_operator.rendered
  filename = "${local.installer_workspace}/portworx_operator.yaml"
}

resource "local_file" "storage_classes_yaml" {
  content  = data.template_file.storage_classes.rendered
  filename = "${local.installer_workspace}/storage_classes.yaml"
}

resource "local_file" "portworx_storagecluster_yaml" {
  content  = data.template_file.portworx_storagecluster.rendered
  filename = "${local.installer_workspace}/portworx_storagecluster.yaml"
}


# resource "null_resource" "login_cluster" {
#   triggers = {
#     openshift_api       = var.openshift_api
#     openshift_username  = var.openshift_username
#     openshift_password  = var.openshift_password
#     openshift_token     = var.openshift_token
#     login_cmd = var.login_cmd
#   }
#   provisioner "local-exec" {
#     command = <<EOF
# ${self.triggers.login_cmd} --insecure-skip-tls-verify || oc login ${self.triggers.openshift_api} -u '${self.triggers.openshift_username}' -p '${self.triggers.openshift_password}' --insecure-skip-tls-verify=true || oc login --server='${self.triggers.openshift_api}' --token='${self.triggers.openshift_token}'
# EOF
#   }
# }

module "dev_cluster" {
  source = "github.com/cloud-native-toolkit/terraform-ocp-login.git"

  server_url = var.server_url
  login_user = var.cluster_username
  login_password = var.cluster_password
  login_token = ""
}

# resource null_resource output_kubeconfig {
#   provisioner "local-exec" {
#     command = "echo '${module.dev_cluster.platform.kubeconfig}' > .kubeconfig"
#   }
# }

resource "null_resource" "install_portworx" {
  count = var.provision ? 1 : 0

  triggers = {
    installer_workspace = local.installer_workspace
    region              = var.region
  }
  provisioner "local-exec" {
    working_dir = "${path.module}/scripts/"
    when        = create
    environment = {
      AWS_ACCESS_KEY_ID = var.access_key
      AWS_SECRET_ACCESS_KEY = var.secret_key
    }
    command     = <<EOF

echo '${module.dev_cluster.platform.kubeconfig}' > .kubeconfig

pwd
chmod +x portworx-prereq.sh
cat ${self.triggers.installer_workspace}/portworx_operator.yaml
oc apply -f ${self.triggers.installer_workspace}/portworx_operator.yaml
echo "Sleeping for 5mins"
sleep 300
echo "Deploying StorageCluster"
oc apply -f ${self.triggers.installer_workspace}/portworx_storagecluster.yaml
sleep 300
echo "Create storage classes"
oc apply -f ${self.triggers.installer_workspace}/storage_classes.yaml
EOF
  }

  depends_on = [
    local_file.portworx_operator_yaml,
    local_file.storage_classes_yaml,
    local_file.portworx_storagecluster_yaml,
    null_resource.portworx_cleanup_helper
  ]
}

# This cleanup script will execute **after** the resources have been reclaimed b/c 
# install_portworx depend on it.  At apply-time it doesn't do anything.
# At destroy-time it will cleanup Portworx artifacts left in the kube cluster.
resource "null_resource" "portworx_cleanup_helper" {
  count = var.provision ? 1 : 0

  triggers = {
    installer_workspace = local.installer_workspace
    region              = var.region
    kubeconfig = module.dev_cluster.platform.kubeconfig
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "echo \"cleanup helper ready\""
  }

  provisioner "local-exec" {
    when = destroy
    # environment = {
    #   CLUSTER    = self.triggers.cluster_name
    #   KUBECONFIG = self.triggers.config_path
    #   BIN_DIR    = self.triggers.bin_dir
    # }

    interpreter = ["/bin/bash", "-c"]
    command     = <<EOF
echo '${self.triggers.kubeconfig}' > .kubeconfig
curl -fsL https://install.portworx.com/px-wipe | bash -s -- -f
EOF
  }
}


resource "null_resource" "enable_portworx_encryption" {
  count = var.portworx_enterprise.enable && var.portworx_enterprise.enable_encryption ? 1 : 0
  triggers = {
    installer_workspace = local.installer_workspace
    region              = var.region
  }
  provisioner "local-exec" {
    when    = create
    command = <<EOF
echo "Enabling encryption"
PX_POD=$(oc get pods -l name=portworx -n kube-system -o jsonpath='{.items[0].metadata.name}')
oc exec $PX_POD -n kube-system -- /opt/pwx/bin/pxctl secrets aws login

kubectl label nodes --all px/enabled=remove --overwrite

kubectl get pods -o wide -n kube-system -l name=portworx

VER=$(kubectl version --short | awk -Fv '/Server Version: /{print $3}')
kubectl delete -f "https://install.portworx.com?ctl=true&kbver=$VER"

kubectl label nodes --all px/enabled-
EOF
  }
  depends_on = [
    null_resource.install_portworx,
  ]
}

locals {
  rootpath            = abspath(path.root)
  installer_workspace = "${local.rootpath}/installer-files"
  px_cluster_id       = var.portworx_essentials.enable ? var.portworx_essentials.cluster_id : var.portworx_enterprise.cluster_id
  priv_image_registry = "image-registry.openshift-image-registry.svc:5000/kube-system"
  secret_provider     = var.portworx_enterprise.enable && var.portworx_enterprise.enable_encryption ? "aws-kms" : "k8s"
  px_workspace        = "${local.installer_workspace}/ibm-px"
}
