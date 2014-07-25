package Device::WebIO::RaspberryPi;

# ABSTRACT: Device::WebIO implementation for the Rapsberry Pi
use v5.12;
use Moo;
use namespace::clean;
use HiPi::Wiring qw( :wiring );

use constant {
    TYPE_REV1         => 0,
    TYPE_REV2         => 1,
    TYPE_MODEL_B_PLUS => 2,
};


sub BUILDARGS
{
    my ($class, $args) = @_;
    my $rpi_type = delete($args->{type}) // $class->TYPE_ORIG;

    $args->{pwm_bit_resolution} = 10;
    $args->{pwm_max_int}        = 2 ** $args->{pwm_bit_resolution};

    if( TYPE_REV1 == $rpi_type ) {
        $args->{input_pin_count}  = 8;
        $args->{output_pin_count} = 8;
        $args->{pwm_pin_count}    = 0;
    }
    elsif( TYPE_REV2 == $rpi_type ) {
        $args->{input_pin_count}  = 8;
        $args->{output_pin_count} = 8;
        $args->{pwm_pin_count}    = 1;
    }
    elsif( TYPE_MODEL_B_PLUS == $rpi_type ) {
        $args->{input_pin_count}  = 17;
        $args->{output_pin_count} = 17;
        $args->{pwm_pin_count}    = 1;
    }
    else {
        die "Don't know what to do with Rpi type '$rpi_type'\n";
    }

    return $args;
}


has 'input_pin_count', is => 'ro';
with 'Device::WebIO::Device::DigitalInput';

sub set_as_input
{
}

sub input_pin
{
}


has 'output_pin_count', is => 'ro';
with 'Device::WebIO::Device::DigitalOutput';

sub set_as_output
{
}

sub output_pin
{
}


has 'pwm_pin_count',      is => 'ro';
has 'pwm_bit_resolution', is => 'ro';
has 'pwm_max_int',        is => 'ro';
with 'Device::WebIO::Device::PWM';

sub pwm_output_int
{
}


# TODO
#with 'Device::WebIO::Device::SPI';
#with 'Device::WebIO::Device::I2C';
#with 'Device::WebIO::Device::Serial';
#with 'Device::WebIO::Device::VideoStream';

1;
