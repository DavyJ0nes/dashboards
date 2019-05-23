local grafana = import '../lib/grafonnet/grafana.libsonnet';

local cloudwatch = grafana.cloudwatch;
local dashboard = grafana.dashboard;
local graph = grafana.graphPanel;
local row = grafana.row;
local singlestat = grafana.singlestat;
local template = grafana.template;

// ***** Variables ***** //

local envVar = {
  "current": {
    "text": "Cloudwatch Prod",
    "value": "CloudWatch Prod"
  },
  "hide": 0,
  "includeAll": false,
  "label": "Env",
  "multi": false,
  "name": "env",
  "options": [],
  "query": "cloudwatch",
  "refresh": 1,
  "regex": "/^Cloud/",
  "skipUrlSync": false,
  "type": "datasource"
};

local regionVar = template.new(
  'region',
  '$env',
  'regions()',
  'Region',
  current='eu-west-1',
  refresh='load'
);

local queueNameVar = template.new(
  'queueName',
  '$env',
  'dimension_values($region,AWS/SQS,NumberOfMessagesSent,QueueName)',
  'Queue Name',
  refresh='load'
);

// ***** Functions ***** //

local SQSTarget(metric, stat='Average') = cloudwatch.target(
  '$region',
  'AWS/SQS',
  metric,
  datasource='$env',
  statistic=stat,
  alias='{{ stat }} {{ metric }}',
  dimensions={ QueueName: '$queueName' }
);

local SingleStat(name, target, fmt='short', span=3) = singlestat.new(
  name,
  datasource='$env',
  format=fmt,
  span=span,
  valueName='current',
  sparklineShow=true
).addTarget(target);

local SimpleGraph(name, targets, fmt='short', span=6) = graph.new(
  name,
  datasource='$env',
  format=fmt,
  span=span,
  nullPointMode='connected',
).addTargets(targets);

// ***** Rows ***** //

local topRow = row.new(
  height='100px'
).addPanels(
  [
    SingleStat('Current Age of Oldest Msg', SQSTarget('ApproximateAgeOfOldestMessage', 'Maximum'), fmt='s'),
    SingleStat('Current Visible Msgs', SQSTarget('ApproximateNumberOfMessagesVisible')),
    SingleStat('Current Messages Received', SQSTarget('NumberOfMessagesReceived')),
    SingleStat('Average Message Size', SQSTarget('SentMessageSize'), fmt='Bps'),
  ]
);

local graphRow = row.new(
).addPanels(
  [
    SimpleGraph(
      'Age of Messages',
      [
        SQSTarget('ApproximateAgeOfOldestMessage'),
        SQSTarget('ApproximateAgeOfOldestMessage', 'Maximum'),
        SQSTarget('ApproximateAgeOfOldestMessage', 'Minimum'),
      ],
      fmt='s',
    ),
    SimpleGraph(
      'Visible Messages',
      [
        SQSTarget('ApproximateNumberOfMessagesVisible'),
        SQSTarget('ApproximateNumberOfMessagesVisible', 'Maximum'),
        SQSTarget('ApproximateNumberOfMessagesVisible', 'Minimum'),
      ]
    ),
    SimpleGraph(
      'Sent and Received Messages',
      [
        SQSTarget('NumberOfMessagesReceived'),
        SQSTarget('NumberOfMessagesSent'),
        SQSTarget('NumberOfMessagesDeleted'),
      ]
    ),
    SimpleGraph(
      'Avg Sent Message Size',
      [
        SQSTarget('SentMessageSize'),
      ]
    ),
  ]
);

// ***** Dashboard ***** //

dashboard.new(
  'SQS',
  refresh='30s',
  time_from='now-30m',
  tags=['cloudwatch', 'queues']
)
.addTemplate(envVar)
.addTemplate(regionVar)
.addTemplate(queueNameVar)
.addRows(
  [
    topRow,
    graphRow,
  ]
)
