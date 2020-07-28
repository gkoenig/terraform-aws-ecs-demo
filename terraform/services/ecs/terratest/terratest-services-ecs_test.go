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

func TestServicesECS(t *testing.T) {

	ecs_clustername := "terratest-ecs-cluster"
	alb_name := "terratest-alb"

	terraformOptions := &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: "../",
		Vars: map[string]interface{}{
			"namespace":       "terratest",
			"stage":           "terraform-testing",
			"ecs-clustername": ecs_clustername,
			"alb-name":        alb_name,
		},
	}

	// At the end of the test, run `terraform destroy` to clean up any resources that were created.
	defer terraform.Destroy(t, terraformOptions)

	// Run `terraform init` and `terraform apply`. Fail the test if there are any errors.
	terraform.InitAndApply(t, terraformOptions)

	// 1. test: check if at least the mandatory tags ("Requestor" and "Customer") are provided
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

	// 2. test: check if the requested ECS cluster name is up and running
	ecscluster := aws.GetEcsCluster(t, "eu-central-1", ecs_clustername)
	assert.Equal(t, ecs_clustername, *ecscluster.ClusterName)

	// 3. test: check if ALb with requested name is up and listening
	albName := terraform.Output(t, terraformOptions, "alb_name")
	// Verify we're getting back the outputs we expect
	assert.Equal(t, alb_name, albName)
}
