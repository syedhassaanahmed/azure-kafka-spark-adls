# azure-kafka-spark-adls
[![Deploy to Azure](http://azuredeploy.net/deploybutton.png)](https://azuredeploy.net/)

This [ARM template](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-authoring-templates) deploys multiple [HDInsight](https://docs.microsoft.com/en-us/azure/hdinsight/hadoop/apache-hadoop-introduction) clusters (`Spark` + `Kafka`) in the same [Virtual Network](https://docs.microsoft.com/en-us/azure/virtual-network/virtual-networks-overview). Spark's storage is primarily backed by [Azure Data Lake Store](https://docs.microsoft.com/en-us/azure/data-lake-store/data-lake-store-overview) while Kafka uses `Blob Storage`.

Since `ADLS` on `HDInsight` requires [Service Principal](https://docs.microsoft.com/en-us/azure/data-lake-store/data-lake-store-service-to-service-authenticate-using-active-directory) with certificate, we've created a `Bash` script to automate entire deployment. Script creates a self-signed certificate and converts it to `PKCS12` format.

## Caveats
- For simplicity we've kept as many resource names as `$CLUSTER_NAME` as possible. 
- `VNet` address space, VM Sizes and number of Head/Worker/`Zookeeper` nodes are hardcoded inside the template.

## Prerequisites
- [Azure CLI 2.0](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
- [OpenSSL](https://www.openssl.org/)

## Deploy
```
./deploy.sh <CLUSTER_NAME>
```
Provide password when prompted. It will be used for accessing all dashboards and `SSH`.
It takes ~20 minutes to deploy all resources.

## Limitations
- It's not possible to create `Service Principal` inside an `ARM` template, since it resides outside  `resource groups`.
- As of now `ADLS` is only [available in these regions](https://azure.microsoft.com/en-us/pricing/details/data-lake-store/).
- `Kafka` doesn't support `ADLS` as primary storage.
- `HDInsight` doesn't allow direct connection to `Kafka` over public internet.
- Once an `HDInsight` cluster is provisioned, only number of worker nodes can be scaled, not the size of VMs.
- Existing `HDInsight` cluster cannot join a new `VNet`.

## Resources
- [Deploy HDInsight clusters with Data Lake Store](https://github.com/Azure/azure-quickstart-templates/tree/master/201-hdinsight-datalake-store-azure-storage)
- [Spark streaming with Kafka on HDInsight](https://docs.microsoft.com/en-us/azure/hdinsight/hdinsight-apache-spark-with-kafka)