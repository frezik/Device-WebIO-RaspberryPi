#!env perl
use v5.14;
use Device::WebIO;
use Device::WebIO::RaspberryPi;
use Time::HiRes 'sleep';

use constant SLEEP_MS   => 0.1;
use constant INPUT_PIN  => 0;
use constant OUTPUT_PIN => 1;


my $rpi = Device::WebIO::RaspberryPi->new;

my $webio = Device::WebIO->new;
$webio->register( 'rpi', $rpi );


while(1) {
    my $in = $webio->digital_input( 'rpi', INPUT_PIN );
    $webio->digital_output( 'rpi', OUTPUT_PIN, $in );
    sleep SLEEP_MS;
}
