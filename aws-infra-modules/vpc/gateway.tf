# -------------------
# Internet Gateway
# -------------------
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.name}-igw"
  }
}

# -------------------
# Elastic IPs for NAT
# -------------------
resource "aws_eip" "nat" {
  count  = 2
  domain = "vpc"

  tags = {
    Name = "${var.name}-nat-eip-${count.index + 1}"
  }
}

# -------------------
# NAT Gateways
# -------------------
resource "aws_nat_gateway" "this" {
  count         = 2
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  depends_on = [aws_internet_gateway.this]

  tags = {
    Name = "${var.name}-nat-${count.index + 1}"
  }
}