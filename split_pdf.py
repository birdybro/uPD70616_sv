#!/usr/bin/env python3
"""
Split a large PDF into smaller sections for easier processing.
"""

import PyPDF2
import os
import sys

def split_pdf(input_pdf, pages_per_section=50, output_dir="pdf_sections"):
    """
    Split a PDF into smaller sections.
    
    Args:
        input_pdf: Path to the input PDF file
        pages_per_section: Number of pages per section (default: 50)
        output_dir: Directory to save the split PDFs
    """
    # Create output directory if it doesn't exist
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)
    
    # Open the PDF
    with open(input_pdf, 'rb') as file:
        reader = PyPDF2.PdfReader(file)
        total_pages = len(reader.pages)
        
        print(f"Total pages: {total_pages}")
        print(f"Pages per section: {pages_per_section}")
        
        # Calculate number of sections
        num_sections = (total_pages + pages_per_section - 1) // pages_per_section
        print(f"Will create {num_sections} sections")
        
        # Split the PDF
        for section in range(num_sections):
            start_page = section * pages_per_section
            end_page = min(start_page + pages_per_section, total_pages)
            
            # Create a new PDF writer for this section
            writer = PyPDF2.PdfWriter()
            
            # Add pages to this section
            for page_num in range(start_page, end_page):
                writer.add_page(reader.pages[page_num])
            
            # Save this section
            output_filename = os.path.join(output_dir, f"section_{section + 1:03d}_pages_{start_page + 1}-{end_page}.pdf")
            with open(output_filename, 'wb') as output_file:
                writer.write(output_file)
            
            print(f"Created: {output_filename}")
        
        print(f"\nSuccessfully split PDF into {num_sections} sections in '{output_dir}' directory")

if __name__ == "__main__":
    # Default to the manual in this repository
    pdf_file = "UPD70616ProgrammersReferenceManual.pdf"
    
    if len(sys.argv) > 1:
        pdf_file = sys.argv[1]
    
    if not os.path.exists(pdf_file):
        print(f"Error: PDF file '{pdf_file}' not found")
        sys.exit(1)
    
    # You can adjust pages_per_section based on your needs
    # Smaller values = more files but smaller size each
    split_pdf(pdf_file, pages_per_section=30)