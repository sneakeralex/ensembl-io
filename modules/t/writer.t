use strict;
use warnings;

use Test::More;

use Bio::EnsEMBL::Utils::IO qw( work_with_file );
use Bio::EnsEMBL::IO::Writer;
use Bio::EnsEMBL::Registry;

## Get some data from the db
my $registry = 'Bio::EnsEMBL::Registry';
$registry->load_registry_from_db(
                      -host => 'ensembldb.ensembl.org',
                      -user => 'anonymous',
                      );
my $slice_adaptor = $registry->get_adaptor('Human', 'Core', 'Slice');
my $gene_adaptor  = $registry->get_adaptor('Human', 'Core', 'Gene');
my $slice = $slice_adaptor->fetch_by_region('chromosome', '6', 133e6, 134e6);
my $genes = $gene_adaptor->fetch_all_by_Slice($slice);

ok(scalar(@$genes) > 0);

my @data;
foreach my $gene (@$genes) {
  push @data, $gene;
  my $transcripts = $gene->get_all_Transcripts;
  foreach (@$transcripts) {
    push @data, $_;
  }  
}

## Create dataset to pass to writer
my $datasets = [{
                'metadata' => {'name' => 'Test 1', 'description' => 'Test of writing genes and their transcripts to a BED file'},
                'data'     => \@data, 
              }];

## Create writer and write data to file
my $writer = Bio::EnsEMBL::IO::Writer->new('Bed', 'output.bed');
$writer->output_file($datasets);

done_testing();