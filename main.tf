locals {
  #px_enterprise       = var.portworx_config.type == "enterprise"
  px_enterprise       = data.external.portworx_config.result.type == "enterprise"
  rootpath            = abspath(path.root)
  installer_workspace = "${local.rootpath}/installer-files"
  #px_cluster_id       = var.portworx_config.cluster_id
  px_cluster_id       = data.external.portworx_config.result.cluster_id
  priv_image_registry = "image-registry.openshift-image-registry.svc:5000/kube-system"
  
  secret_provider     = var.provision && local.px_enterprise && var.enable_encryption ? "aws-kms" : "k8s"
  px_workspace        = "${local.installer_workspace}/ibm-px"
  portworx_spec       = var.portworx_spec_file != null && var.portworx_spec_file != "" ? base64encode(file(var.portworx_spec_file)) : var.portworx_spec  
}

data clis_check clis {
  clis = ["kubectl", "oc", "yq", "jq", "aws"]
}

data external portworx_config {
  program = ["bash", "${path.module}/scripts/parse-portworx-config.sh"]

  query = {
    bin_dir = data.clis_check.clis.bin_dir
    portworx_spec = local.portworx_spec
  }
}

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

resource "local_file" "aws_efs_operator_yaml" {
  content  = data.template_file.aws_efs_operator.rendered
  filename = "${local.installer_workspace}/aws_efs_operator.yaml"
}

resource "null_resource" "install_portworx_prereq" {
  count = var.provision ? 1 : 0
  depends_on = [
    local_file.portworx_operator_yaml,
    local_file.storage_classes_yaml,
    local_file.portworx_storagecluster_yaml,
    local_file.aws_efs_operator_yaml,
  ]
  triggers = {
    installer_workspace = local.installer_workspace
    kubeconfig          = var.cluster_config_file
    BIN_DIR = data.clis_check.clis.bin_dir
    region  = var.region
    access_key= var.access_key
    secret_key = var.secret_key

    
  }
  provisioner "local-exec" {
    when        = create
    environment = {      
      BIN_DIR = self.triggers.BIN_DIR
      INSTALLER_WORKSPACE = self.triggers.installer_workspace
      AWS_ACCESS_KEY_ID =  self.triggers.access_key
      AWS_SECRET_ACCESS_KEY =  self.triggers.secret_key
      KUBECONFIG = self.triggers.kubeconfig
    }
    command     = "${path.module}/scripts/portworx-prereq.sh ${self.triggers.region} true"
  }

   provisioner "local-exec" {
    when        = destroy
    environment = {      
      BIN_DIR = self.triggers.BIN_DIR
      INSTALLER_WORKSPACE = self.triggers.installer_workspace
      AWS_ACCESS_KEY_ID =  self.triggers.access_key
      AWS_SECRET_ACCESS_KEY =  self.triggers.secret_key
      KUBECONFIG = self.triggers.kubeconfig      
    }
    command     = "${path.module}/scripts/portworx-prereq.sh ${self.triggers.region} false"
  }

}

# resource "null_resource" "install_portworx_prereq" {
#   count = var.provision ? 1 : 0

#   triggers = {
#     installer_workspace = local.installer_workspace
#     region              = var.region
#   }
#   provisioner "local-exec" {
#     working_dir = "${path.module}/scripts/"
#     when        = create
#     environment = {
#       AWS_ACCESS_KEY_ID = var.access_key
#       AWS_SECRET_ACCESS_KEY = var.secret_key
#     }
#     command     = <<EOF
# echo '${var.cluster_config_file}' > .kubeconfig
# export KUBECONFIG=${var.cluster_config_file}:$KUBECONFIG

# pwd
# chmod +x portworx-prereq.sh
# bash portworx-prereq.sh ${self.triggers.region}
# EOF
#   }
# }


resource "null_resource" "install_portworx" {
  count = var.provision ? 1 : 0

  depends_on = [
    local_file.portworx_operator_yaml,
    local_file.storage_classes_yaml,
    local_file.portworx_storagecluster_yaml,
    local_file.aws_efs_operator_yaml,
    null_resource.install_portworx_prereq
  ]

  triggers = {
    installer_workspace = local.installer_workspace
    kubeconfig          = var.cluster_config_file
    px_cluster_id       = local.px_cluster_id
    BIN_DIR = data.clis_check.clis.bin_dir

  }
  provisioner "local-exec" {
    when        = create
    environment = {
      BIN_DIR = self.triggers.BIN_DIR
      KUBECONFIG = self.triggers.kubeconfig
      INSTALLER_WORKSPACE = self.triggers.installer_workspace
    }
    command     = "${path.module}/scripts/install-portworx.sh"
  }

  provisioner "local-exec" {
    when = destroy

    interpreter = ["/bin/bash", "-c"]
    environment = {
      BIN_DIR = self.triggers.BIN_DIR
      KUBECONFIG = self.triggers.kubeconfig
    }
    command     = "${path.module}/scripts/uninstall-portworx.sh ${self.triggers.px_cluster_id}"
  }
}


resource "null_resource" "enable_portworx_encryption" {
  count = var.provision && var.enable_encryption ? 1 : 0
  triggers = {
    installer_workspace = local.installer_workspace
    bin_dir = data.clis_check.clis.bin_dir
    kubeconfig          = var.cluster_config_file
  }
  #todo: fix for both azure/aws
  provisioner "local-exec" {
    when    = create
    command = "${path.module}/scripts/enable-encryption.sh '${local.px_enterprise}'"

    environment = {
      BIN_DIR = self.triggers.bin_dir
      KUBECONFIG = self.triggers.kubeconfig
    }
  }
  depends_on = [
    null_resource.install_portworx,
  ]
}