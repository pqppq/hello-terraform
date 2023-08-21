package test

import (
	"fmt"
	"strings"
	"testing"
	"time"

	http_helper "github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestHelloWorldAppExample(t *testing.T) {
	t.Parallel()

	opts := &terraform.Options{
		TerraformDir: "../../examples/hello-world-app/standalone",
		// pass input variables
		Vars: map[string]interface{}{
			"": fmt.Sprintf("test-%s", random.UniqueId()),
			"mysql_config": map[string]interface{}{
				"address": "mock-value-for-test",
				"port":    3306,
			},
		},
	}

	defer terraform.Destroy(t, opts)
	terraform.InitAndApply(t, opts)

	albDnsName := terraform.Output(t, opts, "alb_dns_name")
	url := fmt.Sprintf("http://%s", albDnsName)
	maxRetries := 10
	timeBetweenRetries := 10 * time.Second

	// verify that we get back a 404 with the expected body
	http_helper.HttpGetWithRetryWithCustomValidation(t,
		url,
		nil,
		maxRetries,
		timeBetweenRetries,
		func(status int, body string) bool {
			return status == 200 && strings.Contains(body, "Hello, World")
		})

}
