# terraform-aws-eks-node-termination-handler

## Usage

```
module "node-termination" {
  source = "github.com/provectus/terraform-aws-eks-node-termination-handler"
  argocd =  module.argocd.state
  tags = {}
}
```
