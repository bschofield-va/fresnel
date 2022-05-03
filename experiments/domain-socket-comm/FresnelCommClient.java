import java.net.StandardProtocolFamily;
import java.net.UnixDomainSocketAddress;
import java.nio.ByteBuffer;
import java.nio.channels.SocketChannel;
import java.nio.file.Paths;

class FresnelCommClient {

  String sock;
  String message;

  FresnelCommClient(String sock, String message) {
    this.sock = sock;
    this.message = message;
  }

  void send() throws Exception {
    var socketPath = Paths.get(sock);
    var socketAddress = UnixDomainSocketAddress.of(socketPath);
    SocketChannel channel = SocketChannel.open(StandardProtocolFamily.UNIX);
    channel.connect(socketAddress);

    ByteBuffer buffer = ByteBuffer.allocate(1024);
    buffer.clear();
    buffer.put(message.getBytes());
    buffer.flip();
    while (buffer.hasRemaining()) {
      channel.write(buffer);
    }
  }

  public static void main(String[] args) throws Exception {
    new FresnelCommClient(".fresnel.sock", args[0]).send();
  }
}
