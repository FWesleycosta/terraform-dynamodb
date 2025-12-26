package test

import (
	"fmt"
	"strings"
	"testing"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/dynamodb"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestDynamoDBModule(t *testing.T) {
	t.Parallel()

	// Gera um nome único para evitar conflitos
	uniqueID := strings.ToLower(random.UniqueId())
	tableName := fmt.Sprintf("terratest-dynamodb-%s", uniqueID)

	awsRegion := "us-east-1"

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/complete",

		Vars: map[string]interface{}{
			"table_name":     tableName,
			"aws_region":     awsRegion,
			"billing_mode":   "PAY_PER_REQUEST",
			"hash_key":       "LockID",
			"attribute_name": "LockID",
			"attribute_type": "S",
		},

		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
		},
	})

	// Cleanup: destroy resources após o teste
	defer terraform.Destroy(t, terraformOptions)

	// Init e Apply
	terraform.InitAndApply(t, terraformOptions)

	// Obtém os outputs
	tableARN := terraform.Output(t, terraformOptions, "dynamodb_table_arn")
	tableID := terraform.Output(t, terraformOptions, "dynamodb_table_id")
	outputTableName := terraform.Output(t, terraformOptions, "dynamodb_table_name")
	tableBillingMode := terraform.Output(t, terraformOptions, "dynamodb_table_billing_mode")

	// Validações dos outputs
	assert.Contains(t, tableARN, tableName)
	assert.Equal(t, tableName, tableID)
	assert.Equal(t, tableName, outputTableName)
	assert.Equal(t, "PAY_PER_REQUEST", tableBillingMode)

	// Valida a tabela diretamente na AWS
	validateDynamoDBTable(t, awsRegion, tableName)
}

func TestDynamoDBModuleProvisioned(t *testing.T) {
	t.Parallel()

	uniqueID := strings.ToLower(random.UniqueId())
	tableName := fmt.Sprintf("terratest-dynamodb-prov-%s", uniqueID)

	awsRegion := "us-east-1"

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/complete",

		Vars: map[string]interface{}{
			"table_name":     tableName,
			"aws_region":     awsRegion,
			"billing_mode":   "PROVISIONED",
			"hash_key":       "id",
			"attribute_name": "id",
			"attribute_type": "S",
			"read_capacity":  5,
			"write_capacity": 5,
		},

		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
		},
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	tableARN := terraform.Output(t, terraformOptions, "dynamodb_table_arn")
	tableBillingMode := terraform.Output(t, terraformOptions, "dynamodb_table_billing_mode")

	assert.Contains(t, tableARN, tableName)
	assert.Equal(t, "PROVISIONED", tableBillingMode)

	// Valida capacidade provisionada
	validateDynamoDBTableProvisioned(t, awsRegion, tableName, 5, 5)
}

func validateDynamoDBTable(t *testing.T, region string, tableName string) {
	sess, err := session.NewSession(&aws.Config{
		Region: aws.String(region),
	})
	require.NoError(t, err)

	svc := dynamodb.New(sess)

	input := &dynamodb.DescribeTableInput{
		TableName: aws.String(tableName),
	}

	result, err := svc.DescribeTable(input)
	require.NoError(t, err)

	assert.Equal(t, tableName, *result.Table.TableName)
	assert.Equal(t, "ACTIVE", *result.Table.TableStatus)
	assert.Equal(t, "PAY_PER_REQUEST", *result.Table.BillingModeSummary.BillingMode)
}

func validateDynamoDBTableProvisioned(t *testing.T, region string, tableName string, readCapacity int64, writeCapacity int64) {
	sess, err := session.NewSession(&aws.Config{
		Region: aws.String(region),
	})
	require.NoError(t, err)

	svc := dynamodb.New(sess)

	input := &dynamodb.DescribeTableInput{
		TableName: aws.String(tableName),
	}

	result, err := svc.DescribeTable(input)
	require.NoError(t, err)

	assert.Equal(t, tableName, *result.Table.TableName)
	assert.Equal(t, "ACTIVE", *result.Table.TableStatus)
	assert.Equal(t, readCapacity, *result.Table.ProvisionedThroughput.ReadCapacityUnits)
	assert.Equal(t, writeCapacity, *result.Table.ProvisionedThroughput.WriteCapacityUnits)
}
