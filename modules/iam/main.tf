resource "aws_iam_role" "ecs_task_execution" {
  name = "${var.project}-${var.env}-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Env     = var.env
    Project = var.project
    Name    = "${var.project}-ecs-task-execution-role"
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  depends_on = [aws_iam_role.ecs_task_execution]

  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "ecs_task" {
  name = "${var.project}-${var.env}-ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Env     = var.env
    Project = var.project
    Name    = "${var.project}-${var.env}-ecs-task-role"
  }
}

resource "aws_iam_policy" "ecs_task" {
  name        = "${var.project}-${var.env}-ecs-task-policy"
  description = "Policy for ECS Task Role to access AWS resources"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:*",
          "dynamodb:*"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel",
          "ecs:ExecuteCommand"
        ],
        Resource = "*"
      }
    ]
  })

  tags = {
    Env     = var.env
    Project = var.project
    Name    = "${var.project}-${var.env}-ecs-task-policy"
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task" {
  depends_on = [aws_iam_policy.ecs_task]

  role       = aws_iam_role.ecs_task.name
  policy_arn = aws_iam_policy.ecs_task.arn
}

resource "aws_iam_openid_connect_provider" "github_actions" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["9e99a48a9960b14926bb7f3b4bdf8ce051d08455"]
}

resource "aws_iam_role" "github_actions" {
  name = "${var.project}-github-actions-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = aws_iam_openid_connect_provider.github_actions.arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition : {
          StringEquals : {
            "token.actions.githubusercontent.com:sub" : [
              "repo:metaboatrace/crawlers:ref:refs/heads/main",
            ]
          }
        }
      }
    ]
  })

  tags = {
    Env     = var.env
    Project = var.project
    Name    = "${var.project}-github-actions-role"
  }
}

resource "aws_iam_policy" "github_actions" {
  name = "${var.project}-github-actions-policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:GetAuthorizationToken",
          "ecs:RegisterTaskDefinition",
          "ecs:UpdateService",
          "iam:PassRole"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_actions" {
  depends_on = [aws_iam_policy.github_actions]

  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions.arn
}
