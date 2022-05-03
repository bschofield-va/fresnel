import static java.net.StandardProtocolFamily.UNIX;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.UnixDomainSocketAddress;
import java.nio.ByteBuffer;
import java.nio.channels.ServerSocketChannel;
import java.nio.channels.SocketChannel;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.Optional;
import java.util.concurrent.TimeUnit;

class FresnelCommServer {

  String sock;

  FresnelCommServer(String sock) {
    this.sock = sock;
  }

  void start() throws Exception {
    var socketPath = Paths.get(sock);
    Files.deleteIfExists(socketPath);
    var address = UnixDomainSocketAddress.of(socketPath);

    try (var serverChannel = ServerSocketChannel.open(UNIX)) {
      serverChannel.bind(address);
      while (true) {
        try (var clientChannel = serverChannel.accept()) {
          readSocketMessage(clientChannel).ifPresent(this::eval);
        }
      }
    } finally {
      Files.deleteIfExists(address.getPath());
    }
  }

  private void eval(String commandLine) {
    try {
      System.out.println("$ " + commandLine);
      Process process = Runtime.getRuntime().exec(commandLine);
      BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream()));
      String line = "";
      while ((line = reader.readLine()) != null) {
        System.out.println(line);
      }
      process.waitFor(5, TimeUnit.SECONDS);
      System.out.println(process.exitValue());
    } catch (Exception e) {
      e.printStackTrace();
      ;
    }
  }

  private Optional<String> readSocketMessage(SocketChannel channel) throws IOException {
    ByteBuffer buffer = ByteBuffer.allocate(1024);
    int bytesRead = channel.read(buffer);
    if (bytesRead < 0) return Optional.empty();

    byte[] bytes = new byte[bytesRead];
    buffer.flip();
    buffer.get(bytes);
    String message = new String(bytes);
    return Optional.of(message);
  }

  public static void main(String[] args) throws Exception {
    new FresnelCommServer(".fresnel.sock").start();
  }
}
