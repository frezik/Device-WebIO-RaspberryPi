# Copyright (c) 2014  Timm Murray
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without 
# modification, are permitted provided that the following conditions are met:
# 
#     * Redistributions of source code must retain the above copyright notice, 
#       this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright 
#       notice, this list of conditions and the following disclaimer in the 
#       documentation and/or other materials provided with the distribution.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE 
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
# POSSIBILITY OF SUCH DAMAGE.
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

has pin_desc => (
    is => 'ro',
);


HiPi::Wiring::wiringPiSetup()


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
        $args->{pin_desc}         = $self->_pin_desc_rev1;
    }
    elsif( TYPE_REV2 == $rpi_type ) {
        $args->{input_pin_count}  = 8;
        $args->{output_pin_count} = 8;
        $args->{pwm_pin_count}    = 1;
        $args->{pin_desc}         = $self->_pin_desc_rev2;
    }
    elsif( TYPE_MODEL_B_PLUS == $rpi_type ) {
        $args->{input_pin_count}  = 17;
        $args->{output_pin_count} = 17;
        $args->{pwm_pin_count}    = 1;
        $args->{pin_desc}         = $self->_pin_desc_model_b_plus,
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
    my ($self, $pin) = @_;
    HiPi::Wiring::pinMode( $pin, WPI_INPUT );
    return 1;
}

sub input_pin
{
    my ($self, $pin) = @_;
    my $in = HiPi::Wiring::digitalRead( $pin );
    return $in;
}


has 'output_pin_count', is => 'ro';
with 'Device::WebIO::Device::DigitalOutput';

sub set_as_output
{
    my ($self, $pin) = @_;
    HiPi::Wiring::pinMode( $pin, WPI_OUTPUT );
    return 1;
}

sub output_pin
{
    my ($self, $pin, $value) = @_;
    HiPi::Wiring::digitalWrite( $pin, $value ? WPI_LOW : WPI_HIGH );
    return 1;
}


has 'pwm_pin_count',      is => 'ro';
has 'pwm_bit_resolution', is => 'ro';
has 'pwm_max_int',        is => 'ro';
with 'Device::WebIO::Device::PWM';

{
    my %did_set_pwm;
    sub pwm_output_int
    {
        my ($self, $pin, $val) = @_:
        HiPi::Wiring::pinMode( $pin, WPI_PWM_OUTPUT )
            if ! exists $did_set_pwm_$pin};
        $did_set_pwm{$pin} = 1;

        HiPi::Wiring::pwmWrite( $pin, $val );
        return 1;
    }
}


sub _pin_desc_rev1
{
    my ($self) = @_;
    return [qw{
        V33 V50 2 V50 3 GND 4 14 GND 15 17 18 27 GND 22 23 V33 24 10 GND 9 25
        11 8 GND 7
    }];
}

sub _pin_desc_rev2
{
    my ($self) = @_;
    return [qw{
        V33 V50 2 V50 3 GND 4 14 GND 15 17 18 27 GND 22 23 V33 24 10 GND 9 25
        11 8 GND 7
    }];
}

sub _pin_desc_model_b_plus
{
    my ($self) = @_;
    return [qw{
        V33 V50 2 V50 3 GND 4 14 GND 15 17 18 27 GND 22 23 V33 24 10 GND 9 25
        11 8 GND 7 GND GND 5 GND 6 12 13 GND 19 16 26 20 GND 21
    }];
}


# TODO
#with 'Device::WebIO::Device::SPI';
#with 'Device::WebIO::Device::I2C';
#with 'Device::WebIO::Device::Serial';
#with 'Device::WebIO::Device::VideoStream';

1;
__END__


=head1 NAME

  Device::WebIO::RaspberyPi - Access RaspberryPi pins via Device::WebIO

=head1 SYNOPSIS

    use Device::WebIO;
    use Device::WebIO::RaspberryPi;
    
    my $webio = Device::WebIO->new;
    my $rpi = Device::WebIO::RaspberryPi->new({
    });
    $webio->register( 'foo', $rpi );
    
    my $value = $webio->digital_input( 'foo', 0 );

=head1 DESCRIPTION

Access the Raspberry Pi's pins using Device::WebIO.

After registering this with the main Device::WebIO object, you shouldn't need 
to access anything in the Rpi object.  All access should go through the 
WebIO object.

=head1 IMPLEMENTED ROLES

=over 4

=item * DigitalOutput

=item * DigitalInput

=item * PWM

=back

=head1 LICENSE

Copyright (c) 2014  Timm Murray
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are 
permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, this list of 
      conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of
      conditions and the following disclaimer in the documentation and/or other materials 
      provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS 
OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF 
MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE 
COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) 
HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR 
TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, 
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

=cut
