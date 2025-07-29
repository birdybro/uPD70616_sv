#!/usr/bin/env python3
"""
Split a PDF using basic tools - requires pdftk or qpdf
"""

import os
import subprocess
import sys

def split_pdf_with_qpdf(input_pdf, pages_per_section=30, output_dir="pdf_sections"):
    """
    Split a PDF using qpdf command line tool.
    """
    # Create output directory if it doesn't exist
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)
    
    # First, get the number of pages
    try:
        result = subprocess.run(['qpdf', '--show-npages', input_pdf], 
                              capture_output=True, text=True, check=True)
        total_pages = int(result.stdout.strip())
    except subprocess.CalledProcessError:
        print("Error: qpdf is not installed. Please install it with: sudo apt-get install qpdf")
        return False
    except ValueError:
        print("Error: Could not determine number of pages")
        return False
    
    print(f"Total pages: {total_pages}")
    print(f"Pages per section: {pages_per_section}")
    
    # Calculate number of sections
    num_sections = (total_pages + pages_per_section - 1) // pages_per_section
    print(f"Will create {num_sections} sections")
    
    # Split the PDF
    for section in range(num_sections):
        start_page = section * pages_per_section + 1  # qpdf uses 1-based indexing
        end_page = min(start_page + pages_per_section - 1, total_pages)
        
        output_filename = os.path.join(output_dir, f"section_{section + 1:03d}_pages_{start_page}-{end_page}.pdf")
        
        # Use qpdf to extract pages
        cmd = ['qpdf', input_pdf, '--pages', '.', f'{start_page}-{end_page}', '--', output_filename]
        
        try:
            subprocess.run(cmd, check=True)
            print(f"Created: {output_filename}")
        except subprocess.CalledProcessError as e:
            print(f"Error creating section {section + 1}: {e}")
            return False
    
    print(f"\nSuccessfully split PDF into {num_sections} sections in '{output_dir}' directory")
    return True

def split_pdf_with_pdftk(input_pdf, pages_per_section=30, output_dir="pdf_sections"):
    """
    Split a PDF using pdftk command line tool.
    """
    # Create output directory if it doesn't exist
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)
    
    # First, get the number of pages
    try:
        result = subprocess.run(['pdftk', input_pdf, 'dump_data'], 
                              capture_output=True, text=True, check=True)
        # Parse the output to find NumberOfPages
        for line in result.stdout.split('\n'):
            if line.startswith('NumberOfPages:'):
                total_pages = int(line.split(':')[1].strip())
                break
    except subprocess.CalledProcessError:
        print("Error: pdftk is not installed. Please install it with: sudo apt-get install pdftk")
        return False
    except (ValueError, UnboundLocalError):
        print("Error: Could not determine number of pages")
        return False
    
    print(f"Total pages: {total_pages}")
    print(f"Pages per section: {pages_per_section}")
    
    # Calculate number of sections
    num_sections = (total_pages + pages_per_section - 1) // pages_per_section
    print(f"Will create {num_sections} sections")
    
    # Split the PDF
    for section in range(num_sections):
        start_page = section * pages_per_section + 1
        end_page = min(start_page + pages_per_section - 1, total_pages)
        
        output_filename = os.path.join(output_dir, f"section_{section + 1:03d}_pages_{start_page}-{end_page}.pdf")
        
        # Use pdftk to extract pages
        cmd = ['pdftk', input_pdf, 'cat', f'{start_page}-{end_page}', 'output', output_filename]
        
        try:
            subprocess.run(cmd, check=True)
            print(f"Created: {output_filename}")
        except subprocess.CalledProcessError as e:
            print(f"Error creating section {section + 1}: {e}")
            return False
    
    print(f"\nSuccessfully split PDF into {num_sections} sections in '{output_dir}' directory")
    return True

if __name__ == "__main__":
    # Default to the manual in this repository
    pdf_file = "UPD70616ProgrammersReferenceManual.pdf"
    
    if len(sys.argv) > 1:
        pdf_file = sys.argv[1]
    
    if not os.path.exists(pdf_file):
        print(f"Error: PDF file '{pdf_file}' not found")
        sys.exit(1)
    
    # Try qpdf first, then pdftk
    print("Attempting to split PDF using qpdf...")
    if not split_pdf_with_qpdf(pdf_file):
        print("\nAttempting to split PDF using pdftk...")
        if not split_pdf_with_pdftk(pdf_file):
            print("\nError: Neither qpdf nor pdftk is available.")
            print("Please install one of them:")
            print("  - Ubuntu/Debian: sudo apt-get install qpdf")
            print("  - Or: sudo apt-get install pdftk")
            sys.exit(1)