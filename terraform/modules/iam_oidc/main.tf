#-----Provider details: Box-----
# Provider type
# Select -> OpenID connect
resource "aws_iam_openid_connect_provider" "github" {
    # Provider URL
    url = "https://token.actions.githubusercontent.com"
    # Audience
    client_id_list = ["sts.amazonaws.com"]
    # Thumbprint - AWS removed from new UI but still required in Terraform
    thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
    # tag
    tags = {
        Name = "${var.project_name}-github-oidc-provider"
    }
    #---
    # Click -> "Add provider"
    #---
    #---
    # Click -> "Assign role"
    # Click -> "Create a new role(aws_iam_role)"
    # Click -> "Next"
    #---
  
}
# Create a new role
# Only my specific repo can assume this role
resource "aws_iam_role" "github_actions_role" {
    name = "${var.project_name}-github-actions-role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Action = "sts:AssumeRoleWithWebIdentity"
            Effect = "Allow"
            #----------Step 1 -> Select trusted entity----------
                #-----Trusted entity type: Box-----
                # Trusted entity type
                # Select -> web identity
                # Web identity = Feferated princiapl in Terraform
            Principal = {
                Federated = "arn:aws:iam::${var.aws_account_id}:oidc-provider/token.actions.githubusercontent.com"
            }
            #-----Web identity: Box-----
            
            Condition = {
                # Audience
                # write -> "sts.amazonaws.com"
                StringEquals = {
                    "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
                }
        
                # Github organization 
                # Write -> Zubair-624
                # +
                # GitHub repository - optional
                # Write -> aws-dynamic-website-ec2-rds-cloudfront
                # Merge into One StringLike block:
                StringLike = {
                    "token.actions.githubusercontent.com:sub" = "repo:Zubair-624/${var.github_repo_name}:*"
                }
            }
        }]
    })
    tags = {
        Name = "${var.project_name}-github-actions-role"
    }
  
}
#----------Step 2: Add permisions----------
#-----Permission policies: Box-----
# PowerUserAccess (Policy 1)
# PowerUserAccess -> run terraform apply (EC2, VPC, RDS, S3, CloudFront)
resource "aws_iam_role_policy_attachment" "github_actions_power_user" {
    role = aws_iam_role.github_actions_role.name
    policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
    
  
}
# ← IMPROVED: Replaced IAMFullAccess with a scoped inline policy.
# PowerUserAccess deliberately excludes IAM management to prevent privilege escalation —
# attaching IAMFullAccess alongside it defeats that safeguard, letting this role create
# a new admin identity and assume it. This scoped policy only allows managing IAM
# resources whose names start with this project's prefix.
resource "aws_iam_role_policy" "github_actions_iam_scoped" {
    name = "${var.project_name}-github-actions-iam-scoped"
    role = aws_iam_role.github_actions_role.id
    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Sid    = "ManageProjectRoles"
                Effect = "Allow"
                Action = [
                    "iam:CreateRole",
                    "iam:DeleteRole",
                    "iam:GetRole",
                    "iam:PassRole",
                    "iam:AttachRolePolicy",
                    "iam:DetachRolePolicy",
                    "iam:PutRolePolicy",
                    "iam:DeleteRolePolicy",
                    "iam:GetRolePolicy",
                    "iam:ListRolePolicies",
                    "iam:ListAttachedRolePolicies",
                    "iam:TagRole",
                    "iam:UntagRole"
                ]
                Resource = "arn:aws:iam::${var.aws_account_id}:role/${var.project_name}-*"
            },
            {
                Sid    = "ManageProjectInstanceProfiles"
                Effect = "Allow"
                Action = [
                    "iam:CreateInstanceProfile",
                    "iam:DeleteInstanceProfile",
                    "iam:GetInstanceProfile",
                    "iam:AddRoleToInstanceProfile",
                    "iam:RemoveRoleFromInstanceProfile",
                    "iam:TagInstanceProfile"
                ]
                Resource = "arn:aws:iam::${var.aws_account_id}:instance-profile/${var.project_name}-*"
            },
            {
                Sid    = "ManageOIDCProvider"
                Effect = "Allow"
                Action = [
                    "iam:CreateOpenIDConnectProvider",
                    "iam:DeleteOpenIDConnectProvider",
                    "iam:GetOpenIDConnectProvider",
                    "iam:TagOpenIDConnectProvider",
                    "iam:UpdateOpenIDConnectProviderThumbprint"
                ]
                Resource = "arn:aws:iam::${var.aws_account_id}:oidc-provider/token.actions.githubusercontent.com"
            }
        ]
    })
}