# azure-kafka-spark-adls
[![Deploy to Azure](http://azuredeploy.net/deploybutton.png)](https://azuredeploy.net/)
[![Visualize](http://armviz.io/visualizebutton.png)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fsyedhassaanahmed%2Fazure-kafka-spark-adls%2Fmaster%2Fazuredeploy.json)

This `ARM` template deploys multiple `HDInsight` clusters (`Spark` + `Kafka`) in the same `VNet`. Spark's storage is primarily backed by `ADLS` while Kafka uses `Blob` Storage.

Since ADLS requires `Service Principal` with certificate, we've created a `Bash` script to automate entire deployment. Script creates a self-signed certificate and converts it to `PKCS12` format.

## Caveats
- For simplicity we've kept as many resource names as `$CLUSTER_NAME` as possible. 
- VNet address space, VM Sizes and number of Head/Worker/Zookeeper nodes are hardcoded inside the template.

## Prerequisites
- [Azure CLI 2.0](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
- OpenSSL

## Deploy
```
./deploy.sh <CLUSTER_NAME>
```
Provide password when prompted. It will be used for accessing all dashboards and `SSH`.
It takes ~20 minutes to deploy all resources.

## Limitations
- It's not possible to create Service Principal inside an ARM template, since it lives outside of `resource groups`.
- Kafka doesn't yet support ADLS as primary storage.
- Kafka cluster cannot be reached from outside.
- Once an HDInsight cluster is provisioned, only number of worker nodes can be scaled, not the size of VMs.
- Existing HDInsight cluster cannot join a new VNet.

## Resources
- [Deploy HDInsight clusters with Data Lake Store](https://github.com/Azure/azure-quickstart-templates/tree/master/201-hdinsight-datalake-store-azure-storage)
- [Spark streaming with Kafka on HDInsight](https://docs.microsoft.com/en-us/azure/hdinsight/hdinsight-apache-spark-with-kafka)