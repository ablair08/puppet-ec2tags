
Facter.add(:ec2_region) do
  confine do
    Facter.value(:ec2_metadata)
  end
  setcode do
    region = Facter.value(:ec2_metadata)['placement']['availability-zone'][0..-2]
    region
  end
end

Facter.add(:ec2_tags) do
  confine do
    begin
      require 'aws-sdk'
      true
    rescue LoadError
      false
    end
  end

  confine do
    Facter.value(:ec2_metadata)['iam']['info']
  end

  setcode do
    instance_id = Facter.value('ec2_metadata')['instance-id']
    region = Facter.value(:ec2_metadata)['placement']['availability-zone'][0..-2]
    ec2 = Aws::EC2::Client.new(region: region)
    instance = ec2.describe_instances(instance_ids: [instance_id])
    tags = instance.reservations[0].instances[0].tags
    taghash = { }
    tags.each do |tag|
      taghash[tag['key'].downcase] = tag['value'].downcase
    end
    taghash
  end

  Facter.add(:group) do
    confine do
      Facter.value(:group)
    end
    setcode do
      group = Facter.value(:ec2_tags)['group']
      group
    end
  end

end
