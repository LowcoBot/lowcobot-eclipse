#!/bin/bash

report_file="metrics.txt"
output_folder="output"

echo "Generating report..." 

> "$report_file"
echo "%%%%%% STATS %%%%%%" >> "$report_file"

model_total=$(wc -l < model.flexmi)
model_empty=$(sed '/^\s*$/d' model.flexmi | wc -l)
model_full=$((model_total - model_empty))
echo "\newcommand{\modelTotal}{$model_total}" >> "$report_file"
echo "\newcommand{\modelEmpty}{$model_full}" >> "$report_file"
echo "\newcommand{\modelFull}{$model_empty}" >> "$report_file"

echo "" >> "$report_file"

entities=("Chatbot" "Webpage" "Component" "PlacedComponent" "Endpoint" "Concept" "Intent" "Parameter")
component_like=("Component" "PlacedComponent")

num_all_entities=0
num_all_components=0
for entity in "${entities[@]}"
do
    num_entity=$(grep -c "<$entity" model.flexmi)
    num_all_entities=$((num_all_entities + num_entity))
    if [[ " ${component_like[@]} " =~ " ${entity} " ]]; then
        num_all_components=$((num_all_components + num_entity))
    fi
    echo "\newcommand{\num${entity}s}{$num_entity}" >> "$report_file"
done

echo "\newcommand{\numAllComponents}{$num_all_components}" >> "$report_file"
echo "\newcommand{\numAllEntities}{$num_all_entities}" >> "$report_file"
echo "" >> "$report_file"

num_python_files=$(ls ${output_folder}/*.py | wc -l)
num_defs=$(grep -r "def" ${output_folder}/*.py | wc -l)
num_tools=$(grep -r "@tool" ${output_folder}/*.py | wc -l)
num_files=$(ls ${output_folder} | wc -l)
num_python_files=$(ls ${output_folder}/*.py | wc -l)

echo "\newcommand{\numPythonFiles}{$num_python_files}" >> "$report_file"
echo "\newcommand{\numDefs}{$num_defs}" >> "$report_file"
echo "\newcommand{\numTools}{$num_tools}" >> "$report_file"
echo "\newcommand{\numFiles}{$num_files}" >> "$report_file"

echo "" >> "$report_file"

python_total=$(wc -l ${output_folder}/*.py | tail -n 1 | awk '{print $1}')
python_comment=$(grep -r "# " ${output_folder}/*.py | wc -l | awk '{print $1}')
python_empty=$(grep -r "^\s*$" ${output_folder}/*.py | wc -l | awk '{print $1}')
python_full=$((python_total - python_comment - python_empty))

echo "\newcommand{\pythonTotal}{$python_total}" >> "$report_file"
echo "\newcommand{\pythonComment}{$python_comment}" >> "$report_file"
echo "\newcommand{\pythonEmpty}{$python_empty}" >> "$report_file"
echo "\newcommand{\pythonFull}{$python_full}" >> "$report_file"

echo "" >> "$report_file"

# The throughput is #full python lines / #full model lines
throughput=$(expr $python_full / $model_empty)
echo "\newcommand{\throughput}{$throughput$\times$}" >> "$report_file"

echo "%%%%%% END STATS %%%%%%" >> "$report_file"
echo "Report generated."
