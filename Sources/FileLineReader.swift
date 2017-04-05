//
//  FileLineReader.swift
//  SwiftCodeGenerator
//
//  Created by Scott Lessans on 12/23/16.
//  Copyright © 2016 Scott Lessans. All rights reserved.
//

import Foundation

class FileLineReader  {
    
    let encoding: String.Encoding
    let chunkSize: Int
    let delimeter : Data
    
    private var _fileHandle: FileHandle
    private var _buffer: Data
    private var _finished : Bool
    
    init?(
        path: String,
        delimiter: String = "\n",
        encoding: String.Encoding = .utf8,
        chunkSize: Int = 4096) {
        
        guard let fileHandle = FileHandle(forReadingAtPath: path),
            let delimData = delimiter.data(using: encoding) else {
                return nil
        }
        self.encoding = encoding
        self.chunkSize = chunkSize
        self.delimeter = delimData
        
        self._fileHandle = fileHandle
        self._buffer = Data(capacity: chunkSize)
        self._finished = false
    }
    
    deinit {
        self.close()
    }
    
    /// Return next line, or nil on EOF.
    func nextLine() -> String? {
        // Read data chunks from file until a line delimiter is found:
        while !self._finished {
            if let range = self._buffer.range(of: self.delimeter) {
                // Convert complete line (excluding the delimiter) to a string:
                let line = String(data: self._buffer.subdata(in: 0..<range.lowerBound), encoding: encoding)
                // Remove line (and the delimiter) from the buffer:
                self._buffer.removeSubrange(0..<range.upperBound)
                return line
            }
            let nextData = self._fileHandle.readData(ofLength: chunkSize)
            if nextData.count > 0 {
                self._buffer.append(nextData)
            } else {
                // EOF or read error.
                self._finished = true
                if self._buffer.count > 0 {
                    // Buffer contains last line in file (not terminated by delimiter).
                    return String(data: self._buffer, encoding: self.encoding)
                }
            }
        }
        return nil
    }
    
    /// Start reading from the beginning of file.
    func rewind() {
        self._fileHandle.seek(toFileOffset: 0)
        self._buffer = Data()
        self._finished = false
    }
    
    /// Close the underlying file. No reading must be done after calling this method.
    func close() -> Void {
        self._fileHandle.closeFile()
    }
}

extension FileLineReader : Sequence {
    func makeIterator() -> AnyIterator<String> {
        return AnyIterator {
            return self.nextLine()
        }
    }
}
