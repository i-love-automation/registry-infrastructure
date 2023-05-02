resource "aws_ecr_repository" "api" {
  name                 = "api"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }

  tags = local.tags
}

data "external" "api_image" {
  program = ["bash", "-c", "aws ecr describe-images --repository-name ${aws_ecr_repository.api.name} --query 'sort_by(imageDetails,& imagePushedAt)[-1].imageTags[0]' --output text | { read image_tag; if [ -z \"$image_tag\" ]; then echo '{\"image_tag\": \"\"}'; else echo '{\"image_tag\": \"'$image_tag'\"}'; fi; }"]
}

locals {
  api_image_tag = data.external.api_image.result["image_tag"]
  api_image_url = length(local.api_image_tag) > 0 ? "${aws_ecr_repository.api.repository_url}:${local.api_image_tag}" : ""
}