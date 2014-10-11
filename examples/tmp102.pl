#!env perl
use v5.14;
use Device::WebIO;
use Device::WebIO::RaspberryPi;
use HiPi::Device::I2C ();
use constant DEVICE        => 1;
use constant SLAVE_ADDR    => 0x48;
use constant TEMP_REGISTER => 0x00;
use constant DEBUG         => 0;


my $webio = Device::WebIO->new;
my $rpi   = Device::WebIO::RaspberryPi->new;
$webio->register( 'rpi', $rpi );

while( 1 ) {
    my ($temp1, $temp2) = $webio->i2c_read( 'rpi',
        DEVICE, SLAVE_ADDR, TEMP_REGISTER, 2 );
    my $temp = convert_reading( $temp1, $temp2 );
    say 'Temp: ' . $temp . 'C';
    sleep 1;
}


# Taken from Device::Temperature::TMP102
sub convert_reading
{
    my ( $msb, $lsb ) = @_;

    printf( "msb:     %02x\n", $msb )   if DEBUG;
    printf( "lsb:     %02x\n", $lsb )   if DEBUG;

    my $temp = ( $msb << 8 ) | $lsb;

    # The TMP102 temperature registers are left justified, correctly
    # right justify them
    $temp = $temp >> 4;

    # test for negative numbers
    if ( $temp & ( 1 << 11 ) ) {

    # twos compliment plus one, per the docs
    $temp = ~$temp + 1;

    # keep only our 12 bits
    $temp &= 0xfff;

    # negative
    $temp *= -1;
    }

    # convert to a celsius temp value
    $temp = $temp / 16;

    return $temp;
}
