# Create a cluster 
resource "aws_ecs_cluster" "moon_cluster" {
  name = "moon_cluster"
}

#Create a task definition
resource "aws_ecs_task_definition" "moon-task" {
  family                   = "moon-task" # Naming our first task
  container_definitions    = <<DEFINITION
  [
    {
      "name": "moon-task",
      "image": "${aws_ecr_repository.moon_ecr_repo.repository_url}",
      "essential": true,
      "portMappings": [
        {
          "containerPort": 3000,
          "hostPort": 3000
        }
      ],
      "memory": 512,
      "cpu": 256
    }
  ]
  DEFINITION
  requires_compatibilities = ["FARGATE"] # Stating that we are using ECS Fargate
  network_mode             = "awsvpc"    # Using awsvpc as our network mode as this is required for Fargate
  memory                   = var.memory         # Specifying the memory our container requires
  cpu                      = var.cpu         # Specifying the CPU our container requires
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
}

#Create an IAM role
resource "aws_iam_role" "ecsTaskExecutionRole" {
  name               = "ecsTaskExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

#Create an IAM Policy with full access
resource "aws_iam_role_policy" "moon-policy" {
  name   = "moon-policy"
  role   = aws_iam_role.ecsTaskExecutionRole.name
  policy = file("iam.json") # NOT APPLICABLE TO USE FULLACCESS IN WORKING ENVIRONMENT
}

# create a policy document for IAM role
data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}
#Attaching IAM policy to role 

resource "aws_iam_role_policy_attachment" "ecs-policy-attach" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


#Create an elastic container service
resource "aws_ecs_service" "moon-service" {
  name            = "moon-service"                        # Naming our first service
  cluster         = aws_ecs_cluster.moon_cluster.id             # Referencing our created Cluster
  task_definition = aws_ecs_task_definition.moon-task.arn # Referencing the task our service will spin up
  launch_type     = "FARGATE"
  desired_count   = 3 # Setting the number of containers to 3

  load_balancer {
    target_group_arn = aws_lb_target_group.target_group.arn # Referencing our target group
    container_name   = aws_ecs_task_definition.moon-task.family
    container_port   = var.port_container # Specifying the container port
  }

  network_configuration {
    subnets          = ["${aws_default_subnet.default_subnet_a.id}", "${aws_default_subnet.default_subnet_b.id}", "${aws_default_subnet.default_subnet_c.id}"]
    assign_public_ip = true                                                # Providing our containers with public IPs
    security_groups  = ["${aws_security_group.service_security_group.id}"] # Setting the security group
  }
}

#Create SecurityGroup for ECS
resource "aws_security_group" "service_security_group" {
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    # Only allowing traffic in from the load balancer security group
    security_groups = ["${aws_security_group.load_balancer_security_group.id}"]
  }

  egress {
    from_port   = 0             # Allowing any incoming port
    to_port     = 0             # Allowing any outgoing port
    protocol    = "-1"          # Allowing any outgoing protocol 
    cidr_blocks = [var.all_cidr] # Allowing traffic out to all IP addresses
  }
}