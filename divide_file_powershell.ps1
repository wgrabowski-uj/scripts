# Example PowerShell script to divide a large CSV file into multiple smaller files with a maximum of 10 lines each

# Define the input file and the output file prefix
$inputFile = "KalkulatorGieldowy-eksport.csv"
$outputFilePrefix = "output"

# Read the CSV file into an array of lines
$lines = Get-Content -Path $inputFile -Encoding UTF8

# Initialize a counter for the number of output files
$fileCounter = 1

# Initialize a counter for the lines in each file
$lineCounter = 0

# Initialize an empty array to store lines for the current file
$currentFileLines = @()

# Loop through each line in the input file
foreach ($line in $lines) {
    # Add the line to the current file's lines
    $currentFileLines += $line
    $lineCounter++

    # If we have 10 lines, write them to a new output file
    if ($lineCounter -eq 10) {
        $outputFile = "{0}{1}.csv" -f $outputFilePrefix, $fileCounter
        $currentFileLines | Out-File -FilePath $outputFile

        # Reset the counters and array for the next file
        $fileCounter++
        $lineCounter = 0
        $currentFileLines = @()
    }
}

# If there are remaining lines that haven't been written to a file, write them
if ($currentFileLines.Count -gt 0) {
    $outputFile = "{0}{1}.csv" -f $outputFilePrefix, $fileCounter
    $currentFileLines | Out-File -FilePath $outputFile
}
