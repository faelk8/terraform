resource "aws_iam_role" "node" {
  name = "${var.prefix}-${var.cluster_name}-role-name"
  assume_role_policy = <<POLICY
    {
        "Version": "2012-10-17"
        "Statement": [
            {
                "Effect": "Allow",
                "Principal": {
                    "Service": "ec2.amazonws.com"
                },
                "Action": "sts.AssumeRole"
            }
        ]
    }
  POLICY
}

resource "aws_iam_role_policy_attachment" "node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node.name
}

resource "aws_iam_role_policy_attachment" "node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node.name
}

resource "aws_iam_role_policy_attachment" "node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node.name
}

resource "aws_eks_node_group" "node-1" {
  cluster_name = aws_eks_cluster.cluster.name
  node_group_name = "node-1"
  node_role_arn = aws_iam_role.node.arn
  subnet_ids = aws_subet.subnets[*].id
  instance_types = ["t3.micro"]
  scaling_config {
    desired_size = var.desired_size
    max_size = var.max_size
    min_size = var.min_size
  }
  depends_on = [ 
    aws_cloudwatch_log_group.log,
    aws_iam_role_policy_attachment.cluste-AmazonEKSClusterPolic,
    aws_iam_role_policy_attachment.cluste-AmazonEKSVPCResourceController,
 ]
}

resource "aws_eks_node_group" "node-2" {
  cluster_name = aws_eks_cluster.cluster.name
  node_group_name = "node-2"
  node_role_arn = aws_iam_role.node.arn
  subnet_ids = aws_subet.subnets[*].id
  instance_types = ["t3.micro"]
  scaling_config {
    desired_size = var.desired_size
    max_size = var.max_size
    min_size = var.min_size
  }
  depends_on = [ 
    aws_cloudwatch_log_group.log,
    aws_iam_role_policy_attachment.cluste-AmazonEKSClusterPolic,
    aws_iam_role_policy_attachment.cluste-AmazonEKSVPCResourceController,
 ]
}