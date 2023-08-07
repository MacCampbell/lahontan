#! /usr/bin/perl -w

#06022021
#By Mac Campbell, DrMacCampbell@gmail.com

#A simple script to extract sites from a fasta file.

#08072023
#Using for lahontan 

#We want a tab-delimited input (sites.txt)
#Chrom  Site    Major   Minor MAF
#Easily obtained from a VCF.
# bcftools +fill-tags outputs/101/snps-75-samples-recode-filtered.recode.vcf -- -t MAF | cut -f 1,2,4,5,8 | grep -v "#" > outputs/101/snps-75-samples-recode-filtered.MAF.txt


#Usage
# ./100.1-extract-flanking.pl sites.txt

my $sites=shift;

#Set variables
my $sep ="\t";

#Flanking length
my $buffer=250;


#Reading in fasta and store to memory, takes a lot. It seems that I should make a hash.


my @sites = GetData($sites);


foreach my $site (@sites) {
	my @b = split("\t", $site);
	
	my $chrom=$b[0];
	my $site=$b[1];
	my $major=$b[2];
	my $minor=$b[3];
	my $maf=$b[4];

#Use faidx to make the range of sites we want
$start= $site-$buffer;
$end = $site+$buffer;
`samtools faidx /home/maccamp/genomes/mykiss-genbank/GCF_002163495.1_Omyk_1.0_genomic.fna $chrom:$start-$end	> temp.fasta`;

my $fasta = "temp.fasta";

#Should only have one sequence
my @dat = ReadInFASTA($fasta);
my @a = split($sep, $dat[0]);
my @sequence = split(//, $a[1]);

print ">".$chrom."-site-".$site."-Major-".$major."-Minor-".$minor."-Freq-LCT-".$maf."\n";
print @sequence[(0)..($buffer-1)];
#print $sequence[$site-1]; Replacing site-1 with major/minor
print "[$major/$minor]";
print @sequence[$buffer+1..$buffer+$buffer];
print "\n";

}

`rm temp.fasta`;


exit;

sub GetData {
my $infile = shift;
my @result;

open (INFILE, "<$infile") || die ("Can't open $infile\n");

while (<INFILE>) {
	chomp;
	push (@result,$_);
}

return(@result);

}


sub ReadInFASTA {
    my $infile = shift;
    my @line;
    my $i = -1;
    my @result = ();
    my @seqName = ();
    my @seqDat = ();

    open (INFILE, "<$infile") || die "Can't open $infile\n";

    while (<INFILE>) {
        chomp;
        if (/^>/) {  # name line in fasta format
            $i++;
            s/^>\s*//; s/^\s+//; s/\s+$//;
            $seqName[$i] = $_;
            $seqDat[$i] = "";
        } else {
            s/^\s+//; s/\s+$//;
	    s/\s+//g;                  # get rid of any spaces
            next if (/^$/);            # skip empty line
            s/[uU]/T/g;                  # change U to T
            $seqDat[$i] = $seqDat[$i] . uc($_);
        }

	# checking no occurence of internal separator $sep.
	die ("ERROR: \"$sep\" is an internal separator.  Line $. of " .
	     "the input FASTA file contains this charcter. Make sure this " . 
	     "separator character is not used in your data file or modify " .
	     "variable \$sep in this script to some other character.\n")
	    if (/$sep/);

    }
    close(INFILE);

    foreach my $i (0..$#seqName) {
	$result[$i] = $seqName[$i] . $sep . $seqDat[$i];
    }
    return (@result);
}
