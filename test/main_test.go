package main

import (
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/docker"
	http_helper "github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestTfModule(t *testing.T) {
	// Prepare: Deploy a Grafana instance via docker-compose
	dockerOptions := &docker.Options{
		WorkingDir:  ".",
		ProjectName: "test",
	}
	defer docker.RunDockerCompose(t, dockerOptions, "down", "-v")
	docker.RunDockerCompose(t, dockerOptions, "up", "-d", "--quiet-pull")

	// Wait until Grafana is available
	http_helper.HTTPDoWithRetry(t, "GET", "http://localhost:3000/api/health", nil, nil, 200, 3, 10*time.Second, nil)

	// Now test the module
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: ".",
		NoColor:      true,
	})

	terraform.InitAndPlan(t, terraformOptions)
	defer terraform.Destroy(t, terraformOptions)
	terraform.Apply(t, terraformOptions)

}
