sudo mkdir /tmp/lib 2> /dev/null
sudo mkdir /tmp/lib/aminer 2> /dev/null
sudo rm -r /tmp/lib/aminer/* 2> /dev/null
sudo chown -R aminer:aminer /tmp/lib 2> /dev/null
sudo rm /tmp/syslog 2> /dev/null
touch /tmp/syslog

FILE=demo/AMinerRemoteControl/demo-config.py
sudo aminer --config "$FILE" & > /dev/null

sleep 1

PREFIX="Remote execution response: "
NOT_FOUND_WARNINGS="WARNING: config_properties['Core.PersistencePeriod'] = not found in the old config file.\nWARNING: config_properties['Log.StatisticsLevel'] = not found in the old config file.\nWARNING: config_properties['Log.DebugLevel'] = not found in the old config file.\nWARNING: config_properties['Log.StatisticsPeriod'] = not found in the old config file.\n"
ERROR="Error at:"
exit_code=0

stdout=$(sudo aminerremotecontrol --Exec "print_config_property(analysis_context, 'Core.PersistenceDir')")
expected="$PREFIX'\"Core.PersistenceDir\": /tmp/lib/aminer'"
if [[ "$stdout" != "$expected" ]]; then
	echo "$ERROR error printing 'Core.PersistenceDir'."
	echo "$stdout"
	echo "Expected: $expected"
	echo
	exit_code=1
fi

stdout=$(sudo aminerremotecontrol --Exec "print_config_property(analysis_context, 'Core.PersistencePeriod')")
expected="$PREFIX'\"Resource \\\\\"Core.PersistencePeriod\\\\\" could not be found.\"'"
if [[ "$stdout" != "$expected" ]]; then
	echo "$ERROR error printing 'Core.PersistencePeriod'."
	echo "$stdout"
	echo "Expected: $expected"
	echo
	exit_code=1
fi

# check if proper mail address validation is done.
properties=("'MailAlerting.TargetAddress'" "'MailAlerting.FromAddress'")
# only test 'MailAlerting.TargetAddress' to reduce runtime and expect 'MailAlerting.FromAddress' to work the same way.
properties=("'MailAlerting.TargetAddress'")
valid_addresses=("'test123@gmail.com'" "'root@localhost'" )
error_addresses=("'domain.user1@localhost'" "'root@notLocalhost'")
for property in "${properties[@]}"; do
  for address in "${valid_addresses[@]}"; do
    stdout=$(sudo aminerremotecontrol --Exec "change_config_property(analysis_context, $property, $address)")
    expected="$PREFIX\"$property changed to $address successfully.\""
    if [[ "$stdout" != "$expected" ]]; then
	    echo "$ERROR changing $property to $address."
	    echo "Expected: $expected"
	    echo "$stdout"
	    echo
	    exit_code=1
    fi
  done
  for address in "${error_addresses[@]}"; do
    stdout=$(sudo aminerremotecontrol --Exec "change_config_property(analysis_context, $property, $address)")
    expected="$PREFIX'FAILURE: MailAlerting.TargetAddress and MailAlerting.FromAddress must be email addresses!'"
    if [[ "$stdout" != "$expected" ]]; then
	    echo "$ERROR changing $property to $address."
	    echo "$stdout"
	    echo "Expected: $expected"
	    echo
	    exit_code=1
    fi
  done
done

INTEGER_CONFIG_PROPERTIES=("'MailAlerting.AlertGraceTime'" "'MailAlerting.EventCollectTime'" "'MailAlerting.MinAlertGap'" "'MailAlerting.MaxAlertGap'" "'MailAlerting.MaxEventsPerMessage'" "'Core.PersistencePeriod'" "'Log.StatisticsLevel'" "'Log.DebugLevel'" "'Log.StatisticsPeriod'" "'Resources.MaxMemoryUsage'")
STRING_CONFIG_PROPERTIES=("'MailAlerting.TargetAddress'" "'MailAlerting.FromAddress'" "'MailAlerting.SubjectPrefix'" "'LogPrefix'")

for property in "${STRING_CONFIG_PROPERTIES[@]}"; do
  stdout=$(sudo aminerremotecontrol --Exec "change_config_property(analysis_context, $property, 123)")
  expected="$PREFIX\"FAILURE: the value of the property $property must be of type <class 'str'>!\""
  if [[ "$stdout" != "$expected" ]]; then
	  echo "$ERROR changing $property wrong Type."
	  echo "$stdout"
	  echo "Expected: $expected"
	  echo
	  exit_code=1
  fi
  stdout=$(sudo aminerremotecontrol --Exec "change_config_property(analysis_context, $property, 'root@localhost')")
  expected="$PREFIX\"$property changed to 'root@localhost' successfully.\""
  if [[ "$stdout" != "$expected" ]]; then
	    echo "$ERROR changing $property to 'root@localhost'."
	    echo "$stdout"
	    echo "Expected: $expected"
	    echo
	    exit_code=1
  fi
done

for property in "${INTEGER_CONFIG_PROPERTIES[@]}"; do
  stdout=$(sudo aminerremotecontrol --Exec "change_config_property(analysis_context, $property, '1')")
  expected="$PREFIX\"FAILURE: the value of the property $property must be of type <class 'int'>!\""
  if [[ "$stdout" != "$expected" && "$stdout" != "$PREFIX'FAILURE: it is not safe to run the AMiner with less than 32MB RAM.'" ]]; then
	  echo "$ERROR changing $property wrong Type."
	  echo "$stdout"
	  echo "Expected: $expected"
	  echo
	  exit_code=1
  fi
  stdout=$(sudo aminerremotecontrol --Exec "change_config_property(analysis_context, $property, 1)")
  expected="$PREFIX\"$property changed to '1' successfully.\""
  if [[ "$stdout" != "$expected" && "$stdout" != "$PREFIX'FAILURE: it is not safe to run the AMiner with less than 32MB RAM.'" ]]; then
	    echo "$ERROR changing $property to 1."
	    echo "$stdout"
	    echo "Expected: $expected"
	    echo
	    exit_code=1
  fi
done

properties=("'Log.StatisticsLevel'" "'Log.DebugLevel'")
for property in "${properties[@]}"; do
  value=0
  stdout=$(sudo aminerremotecontrol --Exec "change_config_property(analysis_context, $property, $value)")
  expected="$PREFIX\"$property changed to '$value' successfully.\""
  if [[ "$stdout" != "$expected" ]]; then
      echo "$ERROR changing $property to $value."
      echo "$stdout"
      echo "Expected: $expected"
      echo
      exit_code=1
  fi
  value=1
  stdout=$(sudo aminerremotecontrol --Exec "change_config_property(analysis_context, $property, $value)")
  expected="$PREFIX\"$property changed to '$value' successfully.\""
  if [[ "$stdout" != "$expected" ]]; then
      echo "$ERROR changing $property to $value."
      echo "$stdout"
      echo "Expected: $expected"
      echo
      exit_code=1
  fi
  value=2
  stdout=$(sudo aminerremotecontrol --Exec "change_config_property(analysis_context, $property, $value)")
  expected="$PREFIX\"$property changed to '$value' successfully.\""
  if [[ "$stdout" != "$expected" ]]; then
      echo "$ERROR changing $property to $value."
      echo "$stdout"
      echo "Expected: $expected"
      echo
      exit_code=1
  fi
  value=-1
  stdout=$(sudo aminerremotecontrol --Exec "change_config_property(analysis_context, $property, $value)")
  expected="$PREFIX'FAILURE: STAT_LEVEL $value is not allowed. Allowed STAT_LEVEL values are 0, 1, 2.'"
  if [[ "$stdout" != "$expected" && "$stdout" != "$PREFIX'FAILURE: DEBUG_LEVEL $value is not allowed. Allowed DEBUG_LEVEL values are 0, 1, 2.'" ]]; then
      echo "$ERROR changing $property to $value."
      echo "$stdout"
      echo "Expected: $expected"
      echo
      exit_code=1
  fi
  value=3
  stdout=$(sudo aminerremotecontrol --Exec "change_config_property(analysis_context, $property, $value)")
  expected="$PREFIX'FAILURE: STAT_LEVEL $value is not allowed. Allowed STAT_LEVEL values are 0, 1, 2.'"
  if [[ "$stdout" != "$expected" && "$stdout" != "$PREFIX'FAILURE: DEBUG_LEVEL $value is not allowed. Allowed DEBUG_LEVEL values are 0, 1, 2.'" ]]; then
      echo "$ERROR changing $property to $value."
      echo "$stdout"
      echo "Expected: $expected"
      echo
      exit_code=1
  fi
done

stdout=$(sudo aminerremotecontrol --Exec "rename_registered_analysis_component(analysis_context,'NewMatchPathValueCombo','NewMatchPathValueComboDetector')")
expected="$PREFIX\"Component 'NewMatchPathValueCombo' renamed to 'NewMatchPathValueComboDetector' successfully.\""
if [[ "$stdout" != "$expected" ]]; then
	echo "$ERROR renames the 'NewMatchPathValueCombo' component to 'NewMatchPathValueComboDetector'."
	echo "$stdout"
	echo "Expected: $expected"
	echo
	exit_code=1
fi

stdout=$(sudo aminerremotecontrol --Exec "rename_registered_analysis_component(analysis_context,'NewMatchPathValueComboDetector', 222)")
expected="$PREFIX\"FAILURE: the parameters 'old_component_name' and 'new_component_name' must be of type str.\""
if [[ "$stdout" != "$expected" ]]; then
	echo "$ERROR renames the 'NewMatchPathValueComboDetector' wrong Type. (no string; integer value)"
	echo "$stdout"
	echo "Expected: $expected"
	echo
	exit_code=1
fi

stdout=$(sudo aminerremotecontrol --Exec "rename_registered_analysis_component(analysis_context,'NonExistingDetector','NewMatchPathValueComboDetector')")
expected="$PREFIX\"FAILURE: the component 'NonExistingDetector' does not exist.\""
if [[ "$stdout" != "$expected" ]]; then
	echo "$ERROR renames a non existing component to 'NewMatchPathValueComboDetector'."
	echo "$stdout"
	echo "Expected: $expected"
	echo
	exit_code=1
fi

stdout=$(sudo aminerremotecontrol --Exec "change_attribute_of_registered_analysis_component(analysis_context, 'NewMatchPathValueComboDetector',  'auto_include_flag', False)")
expected="$PREFIX\"'NewMatchPathValueComboDetector.auto_include_flag' changed from False to False successfully.\""
if [[ "$stdout" != "$expected" ]]; then
	echo "$ERROR changes the 'auto_include_flag' of the 'NewMatchPathValueComboDetector' to False."
	echo "$stdout"
	echo "Expected: $expected"
	echo
	exit_code=1
fi

stdout=$(sudo aminerremotecontrol --Exec "change_attribute_of_registered_analysis_component(analysis_context, 'NewMatchPathValueComboDetector',  'auto_include_flag', 'True')")
expected="$PREFIX\"FAILURE: property 'NewMatchPathValueComboDetector.auto_include_flag' must be of type <class 'bool'>!\""
if [[ "$stdout" != "$expected" ]]; then
	echo "$ERROR changes the 'auto_include_flag' of the 'NewMatchPathValueComboDetector' wrong Type."
	echo "$stdout"
	echo "Expected: $expected"
	echo
	exit_code=1
fi

stdout=$(sudo aminerremotecontrol --Exec "print_attribute_of_registered_analysis_component(analysis_context, 'NewMatchPathValueComboDetector',  'target_path_list')")
expected="$PREFIX'\"NewMatchPathValueComboDetector.target_path_list\": [\"/model/IPAddresses/Username\", \"/model/IPAddresses/IP\"]'"
if [[ "$stdout" != "$expected" ]]; then
	echo "$ERROR prints the current list of paths."
	echo "$stdout"
	echo "Expected: $expected"
	echo
	exit_code=1
fi

stdout=$(sudo aminerremotecontrol --Exec "print_attribute_of_registered_analysis_component(analysis_context, 'NewMatchPathValueComboDetector',  'other_path_list')")
expected="$PREFIX\"FAILURE: the component 'NewMatchPathValueComboDetector' does not have an attribute named 'other_path_list'.\""
if [[ "$stdout" != "$expected" ]]; then
	echo "$ERROR prints not existing attribute."
	echo "$stdout"
	echo "Expected: $expected"
	echo
	exit_code=1
fi

stdout=$(sudo aminerremotecontrol --Exec "print_current_config(analysis_context)")
expected="$PREFIX None"
if [[ "$stdout" == "$expected" ]]; then
	echo "$ERROR print config had an execution error."
	echo "$stdout"
	echo "Expected: $expected"
	echo
	exit_code=1
fi

stdout=$(sudo aminerremotecontrol --Exec "add_handler_to_atom_filter_and_register_analysis_component(analysis_context, 'AtomFilter', NewMatchPathDetector(analysis_context.aminer_config, analysis_context.atomizer_factory.atom_handler_list, auto_include_flag=True), 'NewMatchPathDet')")
expected="$PREFIX\"Component 'NewMatchPathDet' added to 'AtomFilter' successfully.\""
if [[ "$stdout" != "$expected" ]]; then
	echo "$ERROR add a new NewMatchPathDetector to the config."
	echo "$stdout"
	echo "Expected: $expected"
	echo
	exit_code=1
fi

stdout=$(sudo aminerremotecontrol --Exec "add_handler_to_atom_filter_and_register_analysis_component(analysis_context, 'AtomFilter', 'StringDetector', 'StringDetector')")
expected="$PREFIX\"FAILURE: 'component' must implement the AtomHandlerInterface!\""
if [[ "$stdout" != "$expected" ]]; then
	echo "$ERROR add a wrong class to the config."
	echo "$stdout"
	echo "Expected: $expected"
	echo
	exit_code=1
fi

stdout=$(sudo aminerremotecontrol --Exec "save_current_config(analysis_context,'/tmp/config.py')")
expected="${PREFIX}\"${NOT_FOUND_WARNINGS}Successfully saved the current config to /tmp/config.py.\""
if [[ "$stdout" != "$expected" ]]; then
	echo "$ERROR save the current config to /tmp/config.py."
	echo "$stdout"
	echo "Expected: $expected"
	echo
	exit_code=1
fi
sudo rm /tmp/config.py

stdout=$(sudo aminerremotecontrol --Exec "save_current_config(analysis_context,'[dd/path/config.py')")
expected="${PREFIX}\"${NOT_FOUND_WARNINGS}FAILURE: file '[dd/path/config.py' could not be found or opened!\""
if [[ "$stdout" != "$expected" ]]; then
	echo "$ERROR save the current config to an invalid path."
	echo "$stdout"
	echo "Expected: $expected"
	echo
	exit_code=1
fi

stdout=$(sudo aminerremotecontrol --Exec "save_current_config(analysis_context,'/notExistingPath/config.py')")
expected="${PREFIX}\"${NOT_FOUND_WARNINGS}FAILURE: file '/notExistingPath/config.py' could not be found or opened!\""
if [[ "$stdout" != "$expected" ]]; then
	echo "$ERROR save the current config to an not existing directory path."
	echo "$stdout"
	echo "Expected: $expected"
	echo
	exit_code=1
fi

stdout=$(sudo aminerremotecontrol --Exec "persist_all()")
expected="${PREFIX}'OK'"
if [[ "$stdout" != "$expected" ]]; then
	echo "$ERROR persist_all."
	echo "$stdout"
	echo "Expected: $expected"
	echo
	exit_code=1
fi

stdout=$(sudo aminerremotecontrol --Exec "create_backup(analysis_context)")
expected="${PREFIX}'Created backup "
if [[ "$stdout" != "$expected"* ]]; then
	echo "$ERROR creating backup."
	echo "$stdout"
	echo "Expected: $expected"
	echo
	exit_code=1
fi

stdout=$(sudo aminerremotecontrol --Exec "list_backups(analysis_context)")
expected="${PREFIX}'\"backups\": ["
if [[ "$stdout" != "$expected"* ]]; then
	echo "$ERROR listing backups."
	echo "$stdout"
	echo "Expected: $expected"
	echo
	exit_code=1
fi

timestamp=$(date +%s)
stdout=$(sudo aminerremotecontrol --Exec "allowlist_event_in_component(analysis_context,'EnhancedNewValueCombo',($timestamp,'/model/path'),allowlisting_data=None)")
expected="${PREFIX}\"Allowlisted path(es) /model/DailyCron/UName, /model/DailyCron/JobNumber with ($timestamp, '/model/path').\""
if [[ "$stdout" != "$expected" ]]; then
	echo "$ERROR allowlist_event EnhancedNewMatchPathDetector."
	echo "$stdout"
	echo "Expected: $expected"
	echo
	exit_code=1
fi

stdout=$(sudo aminerremotecontrol --Exec "allowlist_event_in_component(analysis_context,'MissingMatch',(' ','/model/DiskReport/Space'),allowlisting_data=-1)")
expected="${PREFIX}\"Updated ' ' in '/model/DiskReport/Space' to new interval 2.\""
if [[ "$stdout" != "$expected" ]]; then
	echo "$ERROR allowlist_event MissingMatchPathDetector."
	echo "$stdout"
	echo "Expected: $expected"
	echo
	exit_code=1
fi

stdout=$(sudo aminerremotecontrol --Exec "allowlist_event_in_component(analysis_context,'NewMatchPath','/model/somepath',allowlisting_data=None)")
expected="${PREFIX}'Allowlisted path(es) /model/somepath in Analysis.NewMatchPathDetector.'"
if [[ "$stdout" != "$expected" ]]; then
	echo "$ERROR allowlist_event NewMatchPathDetector."
	echo "$stdout"
	echo "Expected: $expected"
	echo
	exit_code=1
fi

stdout=$(sudo aminerremotecontrol --Exec "allowlist_event_in_component(analysis_context,'NewMatchPathValueComboDetector','/model/somepath',allowlisting_data=None)")
expected="${PREFIX}'Allowlisted path(es) /model/IPAddresses/Username, /model/IPAddresses/IP with /model/somepath.'"
if [[ "$stdout" != "$expected" ]]; then
	echo "$ERROR allowlist_event NewMatchPathValueCombo."
	echo "$stdout"
	echo "Expected: $expected"
	echo
	exit_code=1
fi

stdout=$(sudo aminerremotecontrol --Exec "allowlist_event_in_component(analysis_context,'NewMatchIdValueComboDetector','/model/somepath',allowlisting_data=None)")
expected="${PREFIX}'Allowlisted path(es) /model/type/path/name, /model/type/syscall/syscall with /model/somepath.'"
if [[ "$stdout" != "$expected" ]]; then
	echo "$ERROR allowlist_event NewMatchIdValueComboDetector."
	echo "$stdout"
	echo "Expected: $expected"
	echo
	exit_code=1
fi

stdout=$(sudo aminerremotecontrol --Exec "allowlist_event_in_component(analysis_context,'EventCorrelationDetector','/model/somepath',allowlisting_data=None)")
expected="${PREFIX}'Allowlisted path /model/somepath.'"
if [[ "$stdout" != "$expected" ]]; then
	echo "$ERROR allowlist_event EventCorrelationDetector."
	echo "$stdout"
	echo "Expected: $expected"
	echo
	exit_code=1
fi

stdout=$(sudo aminerremotecontrol --Exec "allowlist_event_in_component(analysis_context,'NewMatchPathValue','/model/somepath',allowlisting_data=None)")
expected="${PREFIX}'Allowlisted path(es) /model/DailyCron/Job Number, /model/IPAddresses/Username with /model/somepath.'"
if [[ "$stdout" != "$expected" ]]; then
	echo "$ERROR allowlist_event NewMatchPathValueDetector."
	echo "$stdout"
	echo "Expected: $expected"
	echo
	exit_code=1
fi

stdout=$(sudo aminerremotecontrol --Exec "blocklist_event_in_component(analysis_context,'EventCorrelationDetector','/model/somepath',blocklisting_data=None)")
expected="${PREFIX}'Blocklisted path /model/somepath.'"
if [[ "$stdout" != "$expected" ]]; then
	echo "$ERROR blocklist_event EventCorrelationDetector."
	echo "$stdout"
	echo "Expected: $expected"
	echo
	exit_code=1
fi

stdout=$(sudo aminerremotecontrol --Exec "blocklist_event_in_component(analysis_context,'EventCorrelationDetector','/model/somepath',blocklisting_data=None)")
expected="${PREFIX}'Blocklisted path /model/somepath.'"
if [[ "$stdout" != "$expected" ]]; then
	echo "$ERROR blocklist_event EventCorrelationDetector."
	echo "$stdout"
	echo "Expected: $expected"
	echo
	exit_code=1
fi

sudo pkill -x aminer
sleep 2 & wait $!

exit $exit_code