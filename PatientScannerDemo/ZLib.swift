// https://stackoverflow.com/a/55558641/2585092

import Foundation
import Compression

func decompressString(_ data: Data) -> String {
  return String(decoding: decompress(data), as: UTF8.self)
}

func decompress(_ data: Data) -> Data {
  let size = 4 * data.count + 8 * 1024
  let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: size)
  let result = data.subdata(in: 2 ..< data.count).withUnsafeBytes ({
    let read = compression_decode_buffer(buffer, size, $0.baseAddress!.bindMemory(to: UInt8.self, capacity: 1),
                                         data.count - 2, nil, COMPRESSION_ZLIB)
    return Data(bytes: buffer, count:read)
  }) as Data
  buffer.deallocate()
  return result
}