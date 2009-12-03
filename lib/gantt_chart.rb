# Builds a GANTT Chart from the given array of task_lists
# It'll need some CSS to display well, for example:
#
# .gantt { margin: 20px; }
#   .row { position: relative; display: block; margin-bottom: 2px; border: 1px solid #aaa; background: #aaa; width: 600px; height: 22px; }
#   .task_list { position: absolute; border: 1px solid #000; background: #5f5; height: 20px; white-space: nowrap; overflow: hidden; cursor: move; }
require 'gantt_chart/base'
require 'gantt_chart/event'