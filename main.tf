
locals {
  resourceGroupNames = var.resourceGroupNames
}

resource "ibm_resource_group" "resource_group" {
  count = var.createResourceGroups ? length(local.resourceGroupNames) : 0

  name  = local.resourceGroupNames[count.index]
}

data "ibm_resource_group" "resource_group" {
  depends_on = [ibm_resource_group.resource_group]
  count = length(local.resourceGroupNames)

  name  = local.resourceGroupNames[count.index]
}

/*** Create Access Groups for Admins and Users ***/

resource "ibm_iam_access_group" "admins" {
  count = length(local.resourceGroupNames)

  name  = "${replace(upper(local.resourceGroupNames[count.index]), "-", "_")}_ADMIN"
}

resource ibm_iam_access_group editors {
  count = length(local.resourceGroupNames)

  name  = "${replace(upper(local.resourceGroupNames[count.index]), "-", "_")}_EDIT"
}

resource ibm_iam_access_group viewers {
  count = length(local.resourceGroupNames)

  name  = "${replace(upper(local.resourceGroupNames[count.index]), "-", "_")}_VIEW"
}

/*** Import resource groups for the Admins Access Groups ***/

/*** Admins Access Groups Policies ***/

resource "ibm_iam_access_group_policy" "admin_policy_1" {
  count = length(local.resourceGroupNames)

  access_group_id = element(ibm_iam_access_group.admins.*.id, count.index)
  roles           = ["Editor", "Manager"]
  resources {
    resource_group_id = element(data.ibm_resource_group.resource_group.*.id, count.index)
  }
}

resource "ibm_iam_access_group_policy" "admin_policy_2" {
  count = length(local.resourceGroupNames)

  access_group_id = element(ibm_iam_access_group.admins.*.id, count.index)
  roles           = ["Viewer"]
  resources {
    resource_group_id = element(data.ibm_resource_group.resource_group.*.id, count.index)
    attributes        = { "resourceType" = "resource-group", "resource" = local.resourceGroupNames[count.index] }
  }
}

resource "ibm_iam_access_group_policy" "admin_policy_3" {
  count = length(local.resourceGroupNames)

  access_group_id = element(ibm_iam_access_group.admins.*.id, count.index)
  roles           = ["Administrator", "Manager"]
  resources {
    service           = "containers-kubernetes"
    resource_group_id = element(data.ibm_resource_group.resource_group.*.id, count.index)
  }
}

resource "ibm_iam_access_group_policy" "admin_policy_4" {
  count = length(local.resourceGroupNames)

  access_group_id = element(ibm_iam_access_group.admins.*.id, count.index)
  roles           = ["Administrator", "Manager"]
  resources {
    service = "container-registry"
  }
}

/*** Editor Access Groups Policies ***/

resource ibm_iam_access_group_policy edit_policy_1 {
  count = length(local.resourceGroupNames)

  access_group_id = element(ibm_iam_access_group.editors.*.id, count.index)
  roles           = ["Viewer", "Manager"]
  resources {
    resource_group_id = element(data.ibm_resource_group.resource_group.*.id, count.index)
  }
}

resource ibm_iam_access_group_policy edit_policy_2 {
  count = length(local.resourceGroupNames)

  access_group_id = element(ibm_iam_access_group.editors.*.id, count.index)
  roles           = ["Viewer"]
  resources {
    resource_group_id = element(data.ibm_resource_group.resource_group.*.id, count.index)
    attributes        = { "resourceType" = "resource-group", "resource" = local.resourceGroupNames[count.index] }
  }
}

resource ibm_iam_access_group_policy edit_policy_3 {
  count = length(local.resourceGroupNames)

  access_group_id = element(ibm_iam_access_group.editors.*.id, count.index)
  roles           = ["Editor", "Writer"]
  resources {
    service           = "containers-kubernetes"
    resource_group_id = element(data.ibm_resource_group.resource_group.*.id, count.index)
  }
}

resource ibm_iam_access_group_policy edit_policy_4 {
  count = length(local.resourceGroupNames)

  access_group_id = element(ibm_iam_access_group.editors.*.id, count.index)
  roles           = ["Reader", "Writer"]
  resources {
    resource_type     = "namespace"
    resource_group_id = element(data.ibm_resource_group.resource_group.*.id, count.index)
    service           = "container-registry"
    region            = var.region
  }
}


/*** Viewer Access Groups Policies ***/

resource ibm_iam_access_group_policy view_policy_1 {
  count = length(local.resourceGroupNames)

  access_group_id = element(ibm_iam_access_group.viewers.*.id, count.index)
  roles           = ["Viewer", "Reader"]
  resources {
    resource_group_id = element(data.ibm_resource_group.resource_group.*.id, count.index)
  }
}

resource ibm_iam_access_group_policy view_policy_2 {
  count = length(local.resourceGroupNames)

  access_group_id = element(ibm_iam_access_group.viewers.*.id, count.index)
  roles           = ["Viewer"]
  resources {
    resource_group_id = element(data.ibm_resource_group.resource_group.*.id, count.index)
    attributes        = { "resourceType" = "resource-group", "resource" = local.resourceGroupNames[count.index] }
  }
}

resource ibm_iam_access_group_policy view_policy_3 {
  count = length(local.resourceGroupNames)

  access_group_id = element(ibm_iam_access_group.viewers.*.id, count.index)
  roles           = ["Viewer", "Reader"]
  resources {
    service           = "containers-kubernetes"
    resource_group_id = element(data.ibm_resource_group.resource_group.*.id, count.index)
  }
}

resource ibm_iam_access_group_policy view_policy_4 {
  count = length(local.resourceGroupNames)

  access_group_id = element(ibm_iam_access_group.viewers.*.id, count.index)
  roles           = ["Viewer", "Reader"]
  resources {
    resource_type     = "namespace"
    resource_group_id = element(data.ibm_resource_group.resource_group.*.id, count.index)
    service           = "container-registry"
    region            = var.region
  }
}
