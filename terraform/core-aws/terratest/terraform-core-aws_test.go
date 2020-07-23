package test

import (
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

var (
	bFoundRequestor bool = false
	bFoundCustomer  bool = false
)

func TestCoreAWS(t *testing.T) {

	terraformOptions := &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: "../",
		Vars: map[string]interface{}{
			"namespace": "terratest",
			"stage":     "terraform-testing",
		},
	}

	// At the end of the test, run `terraform destroy` to clean up any resources that were created.
	defer terraform.Destroy(t, terraformOptions)

	// Run `terraform init` and `terraform apply`. Fail the test if there are any errors.
	terraform.InitAndApply(t, terraformOptions)

	vpcId := terraform.Output(t, terraformOptions, "vpc_id")
	subnets := aws.GetSubnetsForVpc(t, vpcId, "eu-central-1")

	// 1. test: check if we have 2 subnets within our VPC
	require.Equal(t, 2, len(subnets))

	// 2. test: check if all subnets are public
	for i := range subnets {
		assert.True(t, aws.IsPublicSubnet(t, subnets[i].Id, "eu-central-1"))
	}

	// 3. test: check if at least the mandatory tags ("Requestor" and "Customer") are provided
	Tags := terraform.OutputMap(t, terraformOptions, "tags")
	require.GreaterOrEqual(t, 2, len(Tags))
	for i, val := range Tags {
		if strings.ToLower(i) == "requestor" && val != "" {
			bFoundRequestor = true
		} else if strings.ToLower(i) == "customer" && len(val) > 0 {
			bFoundCustomer = true
		}
	}
	assert.True(t, bFoundCustomer)
	assert.True(t, bFoundRequestor)

}
