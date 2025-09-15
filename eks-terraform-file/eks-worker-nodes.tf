#
# EKS Worker Nodes Resources
#  * IAM role allowing Kubernetes actions to access other AWS services
#  * EKS Node Group to launch worker nodes
#

resource "aws_iam_role" "tsp-cluster-node" {
  name = "tsp-cluster-node-${terraform.workspace}"


  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

data "aws_iam_policy_document" "worker_autoscaling" {
  statement {
    sid    = "eksWorkerAutoscalingAll"
    effect = "Allow"

    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
      "ec2:DescribeLaunchTemplateVersions",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "eksWorkerAutoscalingOwn"
    effect = "Allow"

    actions = [
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "autoscaling:UpdateAutoScalingGroup",
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/kubernetes.io/cluster/${aws_eks_cluster.tsp-cluster.id}"
      values   = ["owned"]
    }

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/k8s.io/cluster-autoscaler/enabled"
      values   = ["true"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "workers_autoscaling" {
  policy_arn = aws_iam_policy.worker_autoscaling.arn
  role       = aws_iam_role.tsp-cluster-node.name
}

resource "aws_iam_policy" "worker_autoscaling" {
  name_prefix = "eks-worker-autoscaling-${aws_eks_cluster.tsp-cluster.id}"
  description = "EKS worker node autoscaling policy for cluster ${aws_eks_cluster.tsp-cluster.id}"
  policy      = data.aws_iam_policy_document.worker_autoscaling.json
}



resource "aws_iam_role_policy_attachment" "tsp-cluster-node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.tsp-cluster-node.name
}

resource "aws_iam_role_policy_attachment" "tsp-cluster-node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.tsp-cluster-node.name
}

resource "aws_iam_role_policy_attachment" "tsp-cluster-node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.tsp-cluster-node.name
}

resource "aws_eks_node_group" "tsp-cluster-node-group" {
  cluster_name    = aws_eks_cluster.tsp-cluster.name
  node_group_name = "tsp-cluster-node-group"
  node_role_arn   = aws_iam_role.tsp-cluster-node.arn
  subnet_ids      = aws_subnet.tsp-vpc[*].id
  instance_types  = [var.eks_node_instance_type]
  remote_access {
    ec2_ssh_key = var.key_pair_name
  }


  scaling_config {
    desired_size = 2
    max_size     = 10
    min_size     = 2
  }

  depends_on = [
    aws_iam_role_policy_attachment.workers_autoscaling,
    aws_iam_role_policy_attachment.tsp-cluster-node-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.tsp-cluster-node-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.tsp-cluster-node-AmazonEC2ContainerRegistryReadOnly,
  ]
}

# ------------------------------------------------------------------------------
# ExternalDNS: Add IAM Policy to Allow Route53 DNS Updates
# ------------------------------------------------------------------------------

# ExternalDNS IAM Policy Document
data "aws_iam_policy_document" "external_dns" {
  statement {
    effect = "Allow"
    actions = [
      "route53:ChangeResourceRecordSets",
      "route53:ListResourceRecordSets",
      "route53:ListHostedZones"
    ]
    resources = ["*"]
  }
}

# ExternalDNS IAM Policy
resource "aws_iam_policy" "external_dns" {
  name   = "external-dns-policy-${terraform.workspace}"
  policy = data.aws_iam_policy_document.external_dns.json
}

# Attach ExternalDNS Policy to EKS Node Role
resource "aws_iam_role_policy_attachment" "external_dns_attach" {
  policy_arn = aws_iam_policy.external_dns.arn
  role       = aws_iam_role.tsp-cluster-node.name
}