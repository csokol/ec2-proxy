
CloudFormation {
  Description "Proxy stack"

  EC2_Instance("ProxyEc2Instance") {
    ImageId "ami-6dd04501"
    Property("SecurityGroupIds", ["sg-6365c207"])
    Property("InstanceType", "t2.micro")
    Property("KeyName", "brazil-proxy")
    Property("SubnetId", "subnet-5eca9507")
  }

  Resource("EIP") do
    Type("AWS::EC2::EIP")
    Property("InstanceId", Ref("ProxyEc2Instance"))
    Property("Domain", "vpc")
  end

  Output("InstanceIP") do
    Description("IP of the proxy instance")
    Value(FnJoin("", [Ref("EIP")]))
  end

}