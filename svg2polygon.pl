#!/usr/bin/perl

use strict;
use warnings;

use constant BEZIER_STEP => 0.1;
use constant OUTPUT_GNUPLOT => 0;
use constant OUTPUT_POLYGON => 1;

use XML::Parser;
use Data::Dumper;

my $xml = new XML::Parser(Style => 'tree');
my $svg_parsed = $xml->parsefile($ARGV[0]);
my @patharray;

for( my $i=0; $i<scalar(@$svg_parsed); $i++){
	if( $svg_parsed->[$i] eq "svg" ) {
		for( my $j=0; $j<scalar(@{$svg_parsed->[$i+1]}); $j++){
			if($svg_parsed->[$i+1]->[$j] eq "path"){
				for( my $k=-1; $k<scalar(@{$svg_parsed->[$i+1]->[$j+1]}); $k++){
					if(exists($svg_parsed->[$i+1]->[$j+1]->[$k]{"d"})){
#						print $svg_parsed->[$i+1]->[$j+1]->[$k]{"d"};
#						print "\n";
						push(@patharray, $svg_parsed->[$i+1]->[$j+1]->[$k]{"d"});
					}
				}
			}
		}
	}
}

my $x = 0;
my $y = 0;
my ($c_x1, $c_y1, $c_x2, $c_y2, $c_x, $c_y);
foreach my $path_d(@patharray){
	while(length($path_d)){
		if( $path_d =~ /^\s*z/){
			print "\n";
		}elsif( $path_d =~ /^\s*M(-?[0-9.]+),?(-?[0-9.]+)/){
			$x = $1;
			$y = -1*$2;
			print $x. "\t". $y. "\n"	if OUTPUT_GNUPLOT;
			print "\n". $x. ":". $y. " "	if OUTPUT_POLYGON;
		}elsif( $path_d =~ /^\s*h(-?[0-9.]+)/){
			$x += $1;
			print $x. "\t". $y. "\n"	if OUTPUT_GNUPLOT;
			print $x. ":". $y. " "	if OUTPUT_POLYGON;
		}elsif( $path_d =~ /^\s*H(-?[0-9.]+)/){
			$x = $1;
			print $x. "\t". $y. "\n"	if OUTPUT_GNUPLOT;
			print $x. ":". $y. " "	if OUTPUT_POLYGON;
		}elsif( $path_d =~ /^\s*v(-?[0-9.]+)/){
			$y -= $1;
			print $x. "\t". $y. "\n"	if OUTPUT_GNUPLOT;
			print $x. ":". $y. " "	if OUTPUT_POLYGON;
		}elsif( $path_d =~ /^\s*V(-?[0-9.]+)/){
			$y = -1*$1;
			print $x. "\t". $y. "\n"	if OUTPUT_GNUPLOT;
			print $x. ":". $y. " "	if OUTPUT_POLYGON;
		}elsif( $path_d =~ /^\s*l(-?[0-9.]+),?(-?[0-9.]+)/){
			$x += $1;
			$y -= $2;
			print $x. "\t". $y. "\n"	if OUTPUT_GNUPLOT;
			print $x. ":". $y. " "	if OUTPUT_POLYGON;
		}elsif( $path_d =~ /^\s*L(-?[0-9.]+),?(-?[0-9.]+)/){
			$x = $1;
			$y = -1*$2;
			print $x. "\t". $y. "\n"	if OUTPUT_GNUPLOT;
			print $x. ":". $y. " "	if OUTPUT_POLYGON;
		}elsif( $path_d =~ /^\s*c(-?[0-9.]+),?(-?[0-9.]+),?(-?[0-9.]+),?(-?[0-9.]+),?(-?[0-9.]+),?(-?[0-9.]+)/){
			($c_x1, $c_y1, $c_x2, $c_y2, $c_x, $c_y) = ($1, -1*$2, $3, -1*$4, $5, -1*$6);
#			print $c_x1. ":".$c_y1. ":".$c_x2. ":".$c_y2. ":".$c_x. ":".$c_y. "\n";
			for(my $t=BEZIER_STEP; $t<=1.0; $t+=BEZIER_STEP){
				my $nx = $c_x1*3*$t*((1-$t)**2) + $c_x2*3*($t**2)*(1-$t) + $c_x*($t**3) + $x; 
				my $ny = $c_y1*3*$t*((1-$t)**2) + $c_y2*3*($t**2)*(1-$t) + $c_y*($t**3) + $y;
#				print $t. ":". $nx. "\t". $ny. "\n";
				print $nx. "\t". $ny. "\n"	if OUTPUT_GNUPLOT;
				print $nx. ":". $ny. " "	if OUTPUT_POLYGON;
			}
			$x += $c_x;
			$y += $c_y;
		}elsif( $path_d =~ /^\s*C(-?[0-9.]+),?(-?[0-9.]+),?(-?[0-9.]+),?(-?[0-9.]+),?(-?[0-9.]+),?(-?[0-9.]+)/){
			($c_x1, $c_y1, $c_x2, $c_y2, $c_x, $c_y) = ($1, -1*$2, $3, -1*$4, $5, -1*$6);
#			print $c_x1. ",".$c_y1. ":".$c_x2. ",".$c_y2. ":".$c_x. ",".$c_y. "\n";
			for(my $t=BEZIER_STEP; $t<=1.0; $t+=BEZIER_STEP){
				my $nx = $x*((1-$t)**3) + $c_x1*3*$t*((1-$t)**2) + $c_x2*3*($t**2)*(1-$t) + $c_x*($t**3);
				my $ny;
				$ny = $y*((1-$t)**3) + $c_y1*3*$t*((1-$t)**2) + $c_y2*3*($t**2)*(1-$t) + $c_y*($t**3);
				print $nx. "\t". $ny. "\n"	if OUTPUT_GNUPLOT;
				print $nx. ":". $ny. " "	if OUTPUT_POLYGON;
			}
			$c_x2 -= $x;
			$c_y2 -= $y;
			$x = $c_x;
			$y = $c_y;
		}elsif( $path_d =~ /^\s*s(-?[0-9.]+),?(-?[0-9.]+),?(-?[0-9.]+),?(-?[0-9.]+)/){
			($c_x1, $c_y1) = (-1*$c_x2, -1*$c_y2);
			($c_x2, $c_y2, $c_x, $c_y) = ($1, -1*$2, $3, -1*$4);
#			print $c_x1. ":".$c_y1. ":".$c_x2. ":".$c_y2. ":".$c_x. ":".$c_y. "\n";
			for(my $t=BEZIER_STEP; $t<=1.0; $t+=BEZIER_STEP){
				my $nx = $c_x1*3*$t*((1-$t)**2) + $c_x2*3*($t**2)*(1-$t) + $c_x*($t**3) + $x; 
				my $ny;
				$ny = $c_y1*3*$t*((1-$t)**2) + $c_y2*3*($t**2)*(1-$t) + $c_y*($t**3) + $y;
#				print $t. ":". $nx. "\t". $ny. "\n";
				print $nx. "\t". $ny. "\n"	if OUTPUT_GNUPLOT;
				print $nx. ":". $ny. " "	if OUTPUT_POLYGON;
			}
			$x += $c_x;
			$y += $c_y;
		}else{
			$path_d =~ /[a-zA-Z][^a-zA-Z]+/;
			print "\nError at \"${^MATCH}\"\n";
			exit;
		}
#		print ${^MATCH}."\n";
		$path_d = ${^POSTMATCH};
	}
}
