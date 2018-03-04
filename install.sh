#!/bin/bash

set -e

usage() { 
    echo "Usage: $0 -s stackname -p bucketname" 1>&2
    echo ""
    echo "   -s     Name of CloudFormation Stack to create"
    echo "   -b     Name of S3 Bucket to store lambda code in"
    echo "          Must be in same region as the stack will be deployed"
    echo ""
    exit 1 
}

while getopts ":s:b:" o; do
    case "${o}" in
        s)
            stack=${OPTARG}
            ;;
        b)
            bucket=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${stack}" ] || [ -z "${bucket}" ]; then
    usage
fi

# Create the stack
zip -9 DnsQuery.zip DnsQuery.js
aws cloudformation package --template-file template.yaml --s3-bucket $bucket --output-template-file template.out.yaml >/dev/null
aws cloudformation deploy --template-file template.out.yaml --stack-name $stack --capabilities CAPABILITY_IAM

# Clean up
rm template.out.yaml
rm DnsQuery.zip
