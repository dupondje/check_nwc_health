package Classes::Huawei::Component::EnvironmentalSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);
use strict;

sub init {
  my $self = shift;
  $self->get_snmp_tables('ENTITY-MIB', [
    ['modules', 'entPhysicalTable', 'Classes::Huawei::Component::EnvironmentalSubsystem::Module', sub { my $o = shift; $o->{entPhysicalClass} eq 'module' }, ['entPhysicalClass', 'entPhysicalDescr', 'entPhysicalName']],
    ['fans', 'entPhysicalTable', 'Classes::Huawei::Component::EnvironmentalSubsystem::Fan', sub { my $o = shift; $o->{entPhysicalClass} eq 'fan' }, ['entPhysicalClass', 'entPhysicalDescr', 'entPhysicalName']],
    ['powersupplies', 'entPhysicalTable', 'Classes::Huawei::Component::EnvironmentalSubsystem::Module', sub { my $o = shift; $o->{entPhysicalClass} eq 'powerSupply' }, ['entPhysicalClass', 'entPhysicalDescr', 'entPhysicalName']],
    #['modules', 'entPhysicalTable', 'Classes::Huawei::Component::EnvironmentalSubsystem::Module'],
  ]);
printf "%d modules\n", scalar(@{$self->{modules}});
printf "%d fans\n",  scalar(@{$self->{fans}});
  $self->get_snmp_tables('HUAWEI-ENTITY-EXTENT-MIB', [
    ['entitystates', 'hwEntityStateTable', 'Monitoring::GLPlugin::SNMP::TableItem'],
    ['fanstates', 'hwFanStatusTable', 'Monitoring::GLPlugin::SNMP::TableItem'],
  ]);
  $self->merge_tables("modules", "entitystates");
  $self->merge_tables_with_code("fans", "fanstates", sub {
    my $fan = shift;
    my $fanstate = shift;
printf "-------------->compare %s with %s\n", $fan->{entPhysicalName}, 
sprintf("FAN %d/%d",
        $fanstate->{hwEntityFanSlot}, $fanstate->{hwEntityFanSn});
    return ($fan->{entPhysicalName} eq sprintf("FAN %d/%d",
        $fanstate->{hwEntityFanSlot}, $fanstate->{hwEntityFanSn})) ? 1 : 0;
  });
}


package Classes::Huawei::Component::EnvironmentalSubsystem::Fan;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

package Classes::Huawei::Component::EnvironmentalSubsystem::Module;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

sub finish {
  my $self = shift;
  $self->{name} = $self->{entPhysicalName};
}

sub check {
  my $self = shift;
  my $id = shift;
  $self->add_info(sprintf 'module %s admin status is %s, oper status is %s',
      $self->{name}, $self->{hwEntityAdminStatus}, $self->{hwEntityOperStatus});
  $self->add_info(sprintf 'module %s temperature is %.2f',
      $self->{name}, $self->{hwEntityTemperature});
  $self->set_thresholds(
      metric => 'temp_'.$self->{name},
      warning => $self->{hwEntityTemperatureLowThreshold}.':'.$self->{hwEntityTemperatureThreshold},
      critical => $self->{hwEntityTemperatureLowThreshold}.':'.$self->{hwEntityTemperatureThreshold},
  );
  $self->add_message(
      $self->check_thresholds(
          metric => 'temp_'.$self->{name},
          value => $self->{hwEntityTemperature}
  ));
  $self->add_perfdata(
      label => 'temp_'.$self->{name},
      value => $self->{hwEntityTemperature},
  );
  $self->add_info(sprintf 'module %s fault light is %s',
      $self->{name}, $self->{hwEntityFaultLight});
}


__END__
entPhysicalAlias:
entPhysicalAssetID:
entPhysicalClass: module
entPhysicalContainedIn: 16842752
entPhysicalDescr: Assembling Components-CE5800-CE5850-48T4S2Q-EI-CE5850-48T4S2Q-
EI Switch(48-Port GE RJ45,4-Port 10GE SFP+,2-Port 40GE QSFP+,Without Fan and Pow
er Module)
entPhysicalFirmwareRev: 266
entPhysicalHardwareRev: DE51SRU1B VER D
entPhysicalIsFRU: 1
entPhysicalMfgName: Huawei
entPhysicalModelName:
entPhysicalName: CE5850-48T4S2Q-EI 1
entPhysicalParentRelPos: 1
entPhysicalSerialNum: 210235527210E2000218
entPhysicalSoftwareRev: Version 8.80 V100R003C00SPC600
entPhysicalVendorType: .1.3.6.1.4.1.2011.20021210.12.688138
hwEntityAdminStatus: unlocked
hwEntityEnvironmentalUsage: 14
hwEntityEnvironmentalUsageThreshold: 95
hwEntityFaultLight: normal
hwEntityMemSizeMega: 1837
hwEntityMemUsage: 43
hwEntityMemUsageThreshold: 95
hwEntityOperStatus: enabled
hwEntityPortType: notSupported
hwEntitySplitAttribute:
hwEntityStandbyStatus: providingService
hwEntityTemperature: 33
hwEntityTemperatureLowThreshold: 0
hwEntityTemperatureThreshold: 62
hwEntityUpTime: 34295804
