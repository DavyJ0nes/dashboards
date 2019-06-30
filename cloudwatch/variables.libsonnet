local grafana = import '../lib/grafonnet/grafana.libsonnet';

local template = grafana.template;

local defaultEnv = 'Cloudwatch Prod';

{
  EnvVar: {
    "current": {
      "text": defaultEnv,
      "value": defaultEnv,
    },
    "hide": 0,
    "includeAll": false,
    "label": "Env",
    "multi": false,
    "name": "env",
    "options": [],
    "query": "cloudwatch",
    "refresh": 1,
    "regex": "/Cloud/",
    "skipUrlSync": false,
    "type": "datasource"
  },
  
  RegionVar: template.new(
    'region',
    '$env',
    'regions()',
    'Region',
    current='eu-west-1',
    refresh='load'
  ),
  
  DbNameVar: template.new(
    'dbName',
    '$env',
    'dimension_values($region,AWS/RDS,CPUUtilization,DBInstanceIdentifier)',
    'DB Name',
    refresh='load'
  ),

  QueueNameVar: template.new(
    'queueName',
    '$env',
    'dimension_values($region,AWS/SQS,NumberOfMessagesSent,QueueName)',
    'Queue Name',
    refresh='load'
  )
}