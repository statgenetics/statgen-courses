#!/bin/bash

# Read the CSV file
while IFS=',' read -r name url; do
  # Convert name to lowercase and replace spaces with underscores
  filename=$(echo "$name" | tr '[:upper:]' '[:lower:]' | tr ' ' '_')
  
  # Create the directory for the HTML file
  mkdir -p "$filename"
  
  # Generate the HTML redirect file
  cat > "$filename/index.html" << EOL
<!DOCTYPE html>
<html>
<head>
  <title>$name</title>
  <meta http-equiv="refresh" content="0; URL='$url'" />
</head>
<body>
  <p>Redirecting to <a href="$url">$url</a>...</p>
</body>
</html>
EOL
done < "$1"
