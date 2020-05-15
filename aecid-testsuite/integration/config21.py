config_properties = {}

# Define the list of log resources to read from: the resources
# named here do not need to exist when aminer is started. This
# will just result in a warning. However if they exist, they have
# to be readable by the aminer process! Supported types are:
# * file://[path]: Read data from file, reopen it after rollover
# * unix://[path]: Open the path as UNIX local socket for reading
config_properties['LogResourceList'] = ['file:///tmp/syslog', 'file:///tmp/auth.log']

# Define the uid/gid of the process that runs the calculation
# after opening the log files:
config_properties['AMinerUser'] = 'aminer'
config_properties['AMinerGroup'] = 'aminer'

# Define the path, where aminer will listen for incoming remote
# control connections. When missing, no remote control socket
# will be created.
# config_properties['RemoteControlSocket'] = '/var/run/aminer-remote.socket'

# Read the analyis from this file. That part of configuration
# is separated from the main configuration so that it can be loaded
# only within the analysis child. Non-absolute path names are
# interpreted relatively to the main configuration file (this
# file). When empty, this configuration has to contain the configuration
# for the child also.
# config_properties['AnalysisConfigFile'] = 'analysis.py'

# Read and store information to be used between multiple invocations
# of AMiner in this directory. The directory must only be accessible
# to the 'AMinerUser' but not group/world readable. On violation,
# AMiner will refuse to start. When undefined, '/var/lib/aminer'
# is used.
config_properties['Core.PersistenceDir'] = '/tmp/lib/aminer'

# Define a target e-mail address to send alerts to. When undefined,
# no e-mail notification hooks are added.
config_properties['MailAlerting.TargetAddress'] = 'root@localhost'
# Sender address of e-mail alerts. When undefined, "sendmail"
# implementation on host will decide, which sender address should
# be used.
config_properties['MailAlerting.FromAddress'] = 'root@localhost'
# Define, which text should be prepended to the standard aminer
# subject. Defaults to "AMiner Alerts:"
config_properties['MailAlerting.SubjectPrefix'] = 'AMiner Alerts:'
# Define a grace time after startup before aminer will react to
# an event and send the first alert e-mail. Defaults to 0 (any
# event can immediately trigger alerting).
config_properties['MailAlerting.AlertGraceTime'] = 0
# Define how many seconds to wait after a first event triggered
# the alerting procedure before really sending out the e-mail.
# In that timespan, events are collected and will be sent all
# using a single e-mail. Defaults to 10 seconds.
config_properties['MailAlerting.EventCollectTime'] = 0
# Define the minimum time between two alert e-mails in seconds
# to avoid spamming. All events during this timespan are collected
# and sent out with the next report. Defaults to 600 seconds.
config_properties['MailAlerting.MinAlertGap'] = 0
# Define the maximum time between two alert e-mails in seconds.
# When undefined this defaults to "MailAlerting.MinAlertGap".
# Otherwise this will activate an exponential backoff to reduce
# messages during permanent error states by increasing the alert
# gap by 50% when more alert-worthy events were recorded while
# the previous gap time was not yet elapsed.
config_properties['MailAlerting.MaxAlertGap'] = 600
# Define how many events should be included in one alert mail
# at most. This defaults to 1000
config_properties['MailAlerting.MaxEventsPerMessage'] = 1000
config_properties['LogPrefix'] = 'Original log line: '

# Add your ruleset here:

def build_analysis_pipeline(analysis_context):
  """Define the function to create pipeline for parsing the log
  data. It has also to define an AtomizerFactory to instruct AMiner
  how to process incoming data streams to create log atoms from
  them."""

# Build the parsing model:
  from aminer.parsing import FirstMatchModelElement
  from aminer.parsing import SequenceModelElement

  service_children_disk_upgrade = []

  from aminer.parsing.DateTimeModelElement import DateTimeModelElement
  service_children_disk_upgrade.append(DateTimeModelElement('DTM', b'%Y-%m-%d %H:%M:%S'))
  from aminer.parsing import FixedDataModelElement
  service_children_disk_upgrade.append(FixedDataModelElement('UNameSpace1', b' '))
  from aminer.parsing.DelimitedDataModelElement import DelimitedDataModelElement
  service_children_disk_upgrade.append(DelimitedDataModelElement('UName', b' '))
  service_children_disk_upgrade.append(FixedDataModelElement('UNameSpace2', b' '))
  service_children_disk_upgrade.append(DelimitedDataModelElement('User', b' '))
  service_children_disk_upgrade.append(FixedDataModelElement('HDRepair', b' System rebooted for hard disk upgrade'))

  service_children_home_path = []

  service_children_home_path.append(FixedDataModelElement('Pwd', b'The Path of the home directory shown by pwd of the user '))
  service_children_home_path.append(DelimitedDataModelElement('Username', b' '))
  service_children_home_path.append(FixedDataModelElement('Is', b' is: '))
  from aminer.parsing import AnyByteDataModelElement
  service_children_home_path.append(AnyByteDataModelElement('Path'))

  parsing_model = FirstMatchModelElement('model', [SequenceModelElement('DiskUpgrade', service_children_disk_upgrade), SequenceModelElement('HomePath', service_children_home_path)])

# Some generic imports.
  from aminer.analysis import AtomFilters

# Create all global handler lists here and append the real handlers
# later on.
# Use this filter to distribute all atoms to the analysis handlers.
  atom_filter = AtomFilters.SubhandlerFilter(None)

  from aminer.events.StreamPrinterEventHandler import StreamPrinterEventHandler
  stream_printer_event_handler = StreamPrinterEventHandler(analysis_context)
  from aminer.events.SyslogWriterEventHandler import SyslogWriterEventHandler
  syslog_writer_event_handler = SyslogWriterEventHandler(analysis_context)
  anomaly_event_handlers = [stream_printer_event_handler, syslog_writer_event_handler]

  from aminer.input import SimpleMultisourceAtomSync
  simple_multisource_atom_sync = SimpleMultisourceAtomSync([atom_filter], 9)
  analysis_context.register_component(simple_multisource_atom_sync, component_name="SimpleMultisourceAtomSync")

# Now define the AtomizerFactory using the model. A simple line
# based one is usually sufficient.
  from aminer.input import SimpleByteStreamLineAtomizerFactory
  analysis_context.atomizer_factory = SimpleByteStreamLineAtomizerFactory(
      parsing_model, [simple_multisource_atom_sync], anomaly_event_handlers)

# Just report all unparsed atoms to the event handlers.
  from aminer.input import SimpleUnparsedAtomHandler
  simple_unparsed_atom_handler = SimpleUnparsedAtomHandler(anomaly_event_handlers)
  atom_filter.add_handler(
      simple_unparsed_atom_handler,
      stop_when_handled_flag=True)
  analysis_context.register_component(simple_unparsed_atom_handler, component_name="UnparsedHandler")

  from aminer.analysis import NewMatchPathDetector
  new_match_path_detector = NewMatchPathDetector(
      analysis_context.aminer_config, anomaly_event_handlers, auto_include_flag=True)
  analysis_context.register_component(new_match_path_detector, component_name="NewPath")
  atom_filter.add_handler(new_match_path_detector)

  from aminer.analysis import NewMatchPathValueComboDetector
  new_match_path_value_combo_detector = NewMatchPathValueComboDetector(
  	  analysis_context.aminer_config, ['/model/HomePath/Username', '/model/HomePath/Path'] ,anomaly_event_handlers, auto_include_flag=True)
  analysis_context.register_component(new_match_path_value_combo_detector, component_name="NewValueCombo")
  atom_filter.add_handler(new_match_path_value_combo_detector)

# Include the e-mail notification handler only if the configuration
# parameter was set.
  from aminer.events import DefaultMailNotificationEventHandler
  if DefaultMailNotificationEventHandler.CONFIG_KEY_MAIL_TARGET_ADDRESS in analysis_context.aminer_config.config_properties:
    mail_notification_handler = DefaultMailNotificationEventHandler(analysis_context)
    analysis_context.register_component(
        mail_notification_handler, component_name="MailHandler")
    anomaly_event_handlers.append(mail_notification_handler)