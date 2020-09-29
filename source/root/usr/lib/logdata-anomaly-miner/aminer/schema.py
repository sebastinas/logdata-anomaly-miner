# skipcq: PYL-W0104
{
        'LearnMode': {
            'required': False,
            'type': 'boolean'
        },
        'AMinerUser': {
            'required': False,
            'type': 'string',
            'default': 'aminer'
        },
        'AMinerGroup': {
            'required': False,
            'type': 'string',
            'default': 'aminer'
        },
        'Core.PersistenceDir': {
            'required': False,
            'type': 'string',
            'default': '/var/lib/aminer'
        },
        'MailAlerting.TargetAddress': {
            'required': False,
            'type': 'string'
        },
        'MailAlerting.FromAddress': {
            'required': False,
            'type': 'string'
        },
        'MailAlerting.SubjectPrefix': {
            'required': False,
            'type': 'string',
            'default': 'AMiner Alerts:'
        },
        'MailAlerting.AlertGraceTime': {
            'required': False,
            'type': 'integer',
            'default': 0
        },
        'MailAlerting.EventCollectTime': {
            'required': False,
            'type': 'integer',
            'default': 10
        },
        'MailAlerting.MinAlertGap': {
            'required': False,
            'type': 'integer',
            'default': 600
        },
        'MailAlerting.MaxAlertGap': {
            'required': False,
            'type': 'integer',
            'default': 600
        },
        'MailAlerting.MaxEventsPerMessage': {
            'required': False,
            'type': 'integer',
            'default': 1000
        },
        'LogPrefix': {
            'required': False,
            'type': 'string',
        },
        'LogResourceList': {
            'required': True,
            'type': 'list',
            'schema': {'type': 'string'}
        },
        'Parser': {
            'required': True,
            'type': 'list',
            'has_start': True,
            'schema': {
                'type': 'dict',
                'schema': {
                    'id': {'type': 'string'},
                    'start': {'type': 'boolean'},
                    'type': {'type': 'parsermodel', 'coerce': 'toparsermodel'},
                    'name': {'type': 'string'},
                    'args': {'type': ['string', 'list'], 'schema': {'type': 'string'}}
                }
            }
        },
        'Input': {
            'required': True,
            'type': 'dict',
            'schema': {
                'verbose': {'type': 'boolean', 'required': False, 'default': False},
                'multi_source': {'type': 'boolean', 'required': False, 'default': False},
                'timestamp_path': {'type': ['string', 'list']}
            }
        },
        'Analysis': {
            'required': False,
            'type': 'list',
            'nullable': True,
            'schema': {
                'type': 'dict',
                'schema': {
                    'id': {'type': 'string', 'required': False, 'nullable': True, 'default': None},
                    'type': {'type': 'string', 'allowed': [
                        'NewMatchPathValueDetector', 'NewMatchPathValueComboDetector', 'MissingMatchPathValueDetector',
                        'MissingMatchPathListValueDetector', 'TimeCorrelationDetector', 'ParserCount', 'EventCorrelationDetector',
                        'NewMatchIdValueComboDetector', 'LinearNumericBinDefinition', 'ModuloTimeBinDefinition', 'HistogramAnalysis',
                        'PathDependentHistogramAnalysis', 'EnhancedNewMatchPathValueComboDetector', 'MatchFilter',
                        'MatchValueAverageChangeDetector', 'MatchValueStreamWriter', 'NewMatchPathDetector', 'EventGenerationMatchAction',
                        'AtomFilterMatchAction', 'AndMatchRule', 'OrMatchRule', 'ParallelMatchRule', 'ValueDependentDelegatedMatchRule',
                        'NegationMatchRule', 'PathExistsMatchRule', 'ValueMatchRule', 'ValueListMatchRule', 'ValueRangeMatchRule',
                        'StringRegexMatchRule', 'ModuloTimeMatchRule', 'ValueDependentModuloTimeMatchRule', 'IPv4InRFC1918MatchRule',
                        'DebugMatchRule', 'DebugHistoryMatchRule', 'CorrelationRule', 'EventClassSelector',
                        'TimeCorrelationViolationDetector', 'SimpleMonotonicTimestampAdjust', 'TimestampsUnsortedDetector',
                        'WhitelistViolationDetector']},
                    'paths': {'type': 'list', 'schema': {'type': 'string'}},
                    'learn_mode': {'type': 'boolean'},
                    'persistence_id': {'type': 'string', 'required': False, 'default': 'Default'},
                    'output_log_line': {'type': 'boolean', 'required': False, 'default': True},
                    'allow_missing_values': {'type': 'boolean', 'required': False, 'default': False},
                    'check_interval': {'type': 'integer', 'required': False, 'default': 3600},
                    'realert_interval': {'type': 'integer', 'required': False, 'default': 36000},
                    'report_interval': {'type': 'integer', 'required': False, 'default': 10},
                    'reset_after_report_flag': {'type': 'boolean', 'required': False, 'default': False},
                    'path': {'type': 'string', 'required': False, 'default': 'Default'},
                    'parallel_check_count': {'type': 'integer', 'required': True, 'default': 10},
                    'record_count_before_event': {'type': 'integer', 'required': False, 'default': 1000},
                    'use_path_match': {'type': 'boolean', 'required': False, 'default': True},
                    'use_value_match': {'type': 'boolean', 'required': False, 'default': True},
                    'min_rule_attributes': {'type': 'integer', 'required': False, 'default': 1},
                    'max_rule_attributes': {'type': 'integer', 'required': False, 'default': 5},
                    'max_hypotheses': {'type': 'integer', 'required': False, 'default': 1000},
                    'hypothesis_max_delta_time': {'type': 'float', 'required': False, 'default': 5.0},
                    'generation_probability': {'type': 'float', 'required': False, 'default': 1.0},
                    'generation_factor': {'type': 'float', 'required': False, 'default': 1.0},
                    'max_observations': {'type': 'integer', 'required': False, 'default': 500},
                    'p0': {'type': 'float', 'required': False, 'default': 0.9},
                    'alpha': {'type': 'float', 'required': False, 'default': 0.05},
                    'candidates_size': {'type': 'integer', 'required': False, 'default': 10},
                    'hypotheses_eval_delta_time': {'type': 'float', 'required': False, 'default': 120.0},
                    'delta_time_to_discard_hypothesis': {'type': 'float', 'required': False, 'default': 180.0},
                    'check_rules_flag': {'type': 'boolean', 'required': False, 'default': True},
                    'auto_include_flag': {'type': 'boolean', 'required': False, 'default': True},
                    'whitelisted_paths': {
                        'type': 'list', 'schema': {'type': 'string'}, 'required': False, 'nullable': True, 'default': None},
                    'id_path_list': {'type': 'list', 'required': False, 'default': []},
                    'min_allowed_time_diff': {'type': 'float', 'required': False, 'default': 5.0},
                    'lower_limit': {'type': ['integer', 'float']},
                    'upper_limit': {'type': ['integer', 'float']},
                    'bin_size': {'type': 'integer'},
                    'bin_count': {'type': 'integer'},
                    'outlier_bins_flag': {'type': 'boolean', 'required': False, 'default': False},
                    'modulo_value': {'type': 'integer'},
                    'time_unit': {'type': 'integer'},
                    'histogram_defs': {'type': 'list', 'schema': {'type': 'list', 'schema': {'type': 'string'}}},
                    'bin_definition': {'type': 'string'},
                    'tuple_transformation_function': {'type': 'string'},
                    'value_list': {'type': 'list', 'schema': {'type': ['boolean', 'float', 'integer', 'string']}},
                    'timestamp_path': {'type': 'string'},
                    'min_bin_elements': {'type': 'integer'},
                    'min_bin_time': {'type': 'integer'},
                    'sync_bins_flag': {'type': 'boolean', 'required': False, 'default': True},
                    'debug_mode': {'type': 'boolean', 'required': False, 'default': False},
                    # skipcq: PYL-W0511
                    # TODO check which streams should be allowed
                    'stream': {'type': 'string', 'allowed': ['sys.stdout', 'sys.stderr']},
                    'separator': {'type': 'string'},
                    'missing_value_string': {'type': 'string'},
                    'event_type': {'type': 'string'},
                    'event_message': {'type': 'string'},
                    'stop_when_handled_flag': {'type': 'boolean', 'required': False, 'default': False},
                    'sub_rules': {'type': 'list', 'schema': {'type': 'string'}},
                    'sub_rule': {'type': 'string'},
                    'match_action': {'type': 'string', 'required': False, 'nullable': True, 'default': None},
                    'rule_lookup_dict': {'type': 'dict', 'schema': {'id': {'type': 'string'}, 'type': {'type': 'string'}}},
                    'default_rule': {'type': 'string', 'required': False, 'nullable': True, 'default': None},
                    'value': {'type': ['boolean', 'float', 'integer', 'string']},
                    'regex': {'type': 'string'},
                    'seconds_modulo': {'type': 'integer'},
                    'limit_lookup_dict': {
                        'type': 'dict', 'schema': {'id': {'type': 'string'}, 'type': {'type': 'list', 'schema': {'type': 'integer'}}}},
                    'default_limit': {'type': 'list', 'schema': {'type': 'integer'}, 'required': False, 'nullable': True, 'default': None},
                    'rule_id': {'type': 'string'},
                    'min_time_delta': {'type': 'integer'},
                    'max_time_delta': {'type': 'integer'},
                    'max_artefacts_a_for_single_b': {'type': 'integer'},
                    'artefact_match_parameters': {'type': 'list', 'schema': {'type': 'list', 'schema': {'type': 'string'}},
                                                  'required': False, 'nullable': True, 'default': None},
                    'action_id': {'type': 'string'},
                    'artefact_a_rules': {'type': 'list', 'schema': {'type': 'string'}, 'nullable': True, 'default': None},
                    'artefact_b_rules': {'type': 'list', 'schema': {'type': 'string'}, 'nullable': True, 'default': None},
                    'ruleset': {'type': 'list', 'schema': {'type': 'string'}},
                    'exit_on_error_flag': {'type': 'boolean', 'required': False, 'default': False},
                    'whitelist_rules': {'type': 'list', 'schema': {'type': 'string'}}
                }
            }
        },
        'EventHandlers': {
            'required': False,
            'type': 'list',
            'schema': {
                'type': 'dict',
                'schema': {
                    'id': {'type': 'string'},
                    'type': {'type': 'string', 'allowed': ['StreamPrinterEventHandler', 'SyslogWriterEventHandler']},
                    'json': {'type': 'boolean', 'required': False, 'default': False},
                    'args': {'type': ['string', 'list'], 'schema': {'type': 'string'}}
                }
            }
        }
}

