package test

import (
	"os"
	"testing"
)

const (
	TerraformStateBucketForTestEnvVarName = "TEST_STATE_S3_BUCKET"
	TerraformStateRegionForTestEnvVarName = "TEST_STATE_REGION"
)

func GetRequiredEnvVar(t *testing.T, envVarName string) string {
	envVarValue := os.Getenv(envVarName)

	if envVarValue == "" {
		t.Fatalf("Requied environment variable '%s' is not set", envVarName)
	}

	return envVarValue
}
