#!/usr/bin/env python3
"""
Split a PDF into chunks of 50 pages each
"""

import os
from PyPDF2 import PdfReader, PdfWriter

def split_pdf(input_pdf_path, pages_per_chunk=50):
    """Split a PDF into multiple PDFs with specified pages per chunk"""
    
    # Get the base name without extension
    base_name = os.path.splitext(os.path.basename(input_pdf_path))[0]
    output_dir = os.path.dirname(input_pdf_path)
    
    # Open the PDF
    with open(input_pdf_path, 'rb') as file:
        pdf_reader = PdfReader(file)
        total_pages = len(pdf_reader.pages)
        
        print(f"Total pages: {total_pages}")
        print(f"Splitting into chunks of {pages_per_chunk} pages...")
        
        # Calculate number of chunks
        num_chunks = (total_pages + pages_per_chunk - 1) // pages_per_chunk
        
        # Process each chunk
        for chunk_num in range(num_chunks):
            start_page = chunk_num * pages_per_chunk
            end_page = min(start_page + pages_per_chunk, total_pages)
            
            # Create a new PDF writer for this chunk
            pdf_writer = PdfWriter()
            
            # Add pages to this chunk
            for page_num in range(start_page, end_page):
                pdf_writer.add_page(pdf_reader.pages[page_num])
            
            # Generate output filename
            output_filename = f"{base_name}_pages_{start_page+1:04d}-{end_page:04d}.pdf"
            output_path = os.path.join(output_dir, output_filename)
            
            # Write the chunk
            with open(output_path, 'wb') as output_file:
                pdf_writer.write(output_file)
            
            print(f"Created: {output_filename} (pages {start_page+1} to {end_page})")
        
        print(f"\nCompleted! Split into {num_chunks} files.")

if __name__ == "__main__":
    # Path to the programmer's manual
    pdf_path = "UPD70616ProgrammersReferenceManual.pdf"
    
    if os.path.exists(pdf_path):
        split_pdf(pdf_path, pages_per_chunk=50)
    else:
        print(f"Error: PDF file '{pdf_path}' not found!")