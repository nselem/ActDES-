use strict;
use warnings;
####################################################
######### Description  
#### nselem84@gmail.com
####################################################
#  1. Creates a list that compares functions between GENOMES
## 2. The table contains the number of pegs that are doing the same function
#     Uses bindings files from the tar download from RAST

######### Subs and variables #######################
my @GENOMES=qx/ls data\/bindings\/*.bindings/; ## Read all cvs
my @ID=qx/ls data\/annotations\/*.txt/; ## Read all text files
my $N=scalar @GENOMES; ## Number of files
my %GENOME_NAMES; ## Hash Genome_Id -> Organisms Name
my %FUNC;
my %GENES;
my @functions;
my $Id_file=$ARGV[0];

sub readOrganisms;
sub CountFunctions;
sub headers;
sub Output;


####################################################
#################################
###### Main program
####################################################
%GENOME_NAMES=readOrganisms($Id_file,@ID); ##Read txt files and fill Hash Genome_Id -> Organisms Name
%FUNC=CountFunctions($N,\%GENES,@GENOMES); ##Store in FUNC The number of fucntion and in GENES the pegs of the functions
headers(\%GENOME_NAMES,@GENOMES);	
Output($N,\%GENES,%FUNC);
####################################################
####################################################


sub readOrganisms{
	my $file=shift;
	my @ID=@_;
	my %GENOME_NAMES;
	open(FILE,"data/$file") or die "Could not open file $file $!";
	foreach my $ID(@ID){
		#print "En el for ID $ID\n";
		while ( my $line = <FILE> ) {
			$line=~s/\n|\r//g;
			my @st=split("\t",$line);
			my $Id=$st[0];
			my $name=$st[2];
			$GENOME_NAMES{$Id}=$name;
			print "$Id => $GENOME_NAMES{$Id}\n";
			}
		}
	close FILE; 
	return (%GENOME_NAMES);
	}
#................................................................

sub CountFunctions{
	my $N=shift;
	my $refGENES=shift;
	my @GENOMES=@_;
	my $count=0;
	my %FUNC;		

	foreach my $genome(@GENOMES){
		chomp $genome;
		print "genome: $genome count $count\n";
		open(FILE,$genome) or die "Could not open file $genome $!";	
		my %FUNCTION; ##For each genome a Hash of array HAsh keys:functions Array Contents: gene with that function

		while ( my $line = <FILE> ) {
			my @st=split("\t",$line); 
			my $func=$st[1];
			my $gen=$st[2];
			chomp $gen;
			#print "#$gen# GEn \n";

			if(!exists $FUNCTION{$func}) { 
			#print "New Function $func !!! \n ";
				$FUNCTION{$func}=[];
				}
			
			if (!($gen~~$FUNCTION{$func})){
				push (@{$FUNCTION{$func}}, $gen);
				my $size=scalar @{$FUNCTION{$func}};
				#print "Size $size \n";
				#print "$func => @{$FUNCTION{$func}}\n";
				}
	
			}

		close FILE;
			
		foreach my $element(keys %FUNCTION){  ##Looking the function of the genome number $count
			if(!exists $FUNC{$element}) {  
   				## IF not exists FUNC function creates an array for all the genomes with zeros
				$FUNC{$element} = [];
				$refGENES->{$element}=[];
				for (my $i=0;$i<$N;$i++){ 
					$FUNC{$element}[$i]=0;
					$refGENES->{$element}[$i]="";
					}
				}		
			##In the corresponding genome fill the number of gene with that function
			$FUNC{$element}[$count]=scalar @{$FUNCTION{$element}};	
			$refGENES->{$element}[$count]=join(',', @{ $FUNCTION{$element} } );		
			}			
		$count++; 

		}

	return %FUNC;
	}


sub headers{	
	my $refNAMES=shift;
	my @GENOMES=@_;

	open (FILE,">output/FunctionTable.csv") or die "Could not open file Salida $!";
	open (PEGS,">output/PegsTable.csv") or die "Could not open file Salida $!";
	my $headers="FUNCTION\t";
	foreach my $genome(@GENOMES){
		chomp $genome;
		$genome=~s/\.bindings//;
		$genome=~s/data\/bindings\///;
		print "#$genome# => #$refNAMES->{$genome}#\n";
		$headers=$headers.$refNAMES->{$genome}."\t";
		}
	print FILE "$headers\n";	
	print PEGS "$headers\n";	
	close FILE;
	close PEGS;
	}


sub Output{
	my $N=shift;
	my $refGENES=shift;
	my %FUNC=(@_);

	open (FILE,">>output/FunctionTable.csv") or die "Could not open file Salida $!";
	open (PEGS,">>output/PegsTable.csv") or die "Could not open file Salida $!";

	foreach my $func(sort keys %FUNC){
		#print "$func\n";
		my $line = $func."\t";
		my $peg= $func."\t";

		for (my $i=0;$i<$N;$i++){ 
			my $numberFunc=scalar $FUNC{$func}[$i];
			$line=$line.$numberFunc."\t";
			$peg=$peg.$refGENES->{$func}[$i]."\t";
			}

		print FILE "$line\n";		
		print PEGS "$peg\n";
		}
	close FILE;
	close PEGS;
	}
