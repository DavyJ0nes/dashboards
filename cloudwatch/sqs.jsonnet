local grafana = import '../lib/grafonnet/grafana.libsonnet';
local vars = import './variables.libsonnet';
local funcs = import './functions.libsonnet';

local dashboard = grafana.dashboard;
local row = grafana.row;

// ***** Rows ***** //

local topRow = row.new(
  height='100px'
).addPanels(
  [
    funcs.SQSSingleStat('Current Age of Oldest Msg', funcs.SQSTarget('ApproximateAgeOfOldestMessage', 'Maximum'), fmt='s'),
    funcs.SQSSingleStat('Current Visible Msgs', funcs.SQSTarget('ApproximateNumberOfMessagesVisible')),
    funcs.SQSSingleStat('Current Messages Received', funcs.SQSTarget('NumberOfMessagesReceived')),
    funcs.SQSSingleStat('Average Message Size', funcs.SQSTarget('SentMessageSize'), fmt='Bps'),
  ]
);

local graphRow = row.new(
).addPanels(
  [
    funcs.SQSSimpleGraph(
      'Age of Messages',
      [
        funcs.SQSTarget('ApproximateAgeOfOldestMessage'),
        funcs.SQSTarget('ApproximateAgeOfOldestMessage', 'Maximum'),
        funcs.SQSTarget('ApproximateAgeOfOldestMessage', 'Minimum'),
      ],
      fmt='s',
    ),
    funcs.SQSSimpleGraph(
      'Visible Messages',
      [
        funcs.SQSTarget('ApproximateNumberOfMessagesVisible'),
        funcs.SQSTarget('ApproximateNumberOfMessagesVisible', 'Maximum'),
        funcs.SQSTarget('ApproximateNumberOfMessagesVisible', 'Minimum'),
      ]
    ),
    funcs.SQSSimpleGraph(
      'Sent and Received Messages',
      [
        funcs.SQSTarget('NumberOfMessagesReceived'),
        funcs.SQSTarget('NumberOfMessagesSent'),
        funcs.SQSTarget('NumberOfMessagesDeleted'),
      ]
    ),
    funcs.SQSSimpleGraph(
      'Avg Sent Message Size',
      [
        funcs.SQSTarget('SentMessageSize'),
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
.addTemplate(vars.EnvVar)
.addTemplate(vars.RegionVar)
.addTemplate(vars.QueueNameVar)
.addRows(
  [
    topRow,
    graphRow,
  ]
)
