resource "aws_eip" "excalidraw_eip" {
  domain = "vpc"

  tags = {
    Name = "excalidraw_eip"
  }
}

resource "aws_eip_association" "excalidraw_eip_association" {
  instance_id   = aws_instance.excalidraw_server.id
  allocation_id = aws_eip.excalidraw_eip.id
}
