NVCC = nvcc
CXXFLAGS = -std=c++17 -I./include
LDFLAGS = -lnppif -lnppig -lnppi -lnppc

SRCDIR = src
INCDIR = include
OBJDIR = obj
BINDIR = bin

SRC = $(wildcard $(SRCDIR)/*.cu)
OBJ = $(SRC:$(SRCDIR)/%.cu=$(OBJDIR)/%.o)

TARGET = $(BINDIR)/edge_detection

all: $(TARGET)

$(TARGET): $(OBJ)
	@mkdir -p $(BINDIR)
	$(NVCC) $(CXXFLAGS) -o $@ $^ $(LDFLAGS)

$(OBJDIR)/%.o: $(SRCDIR)/%.cu
	@mkdir -p $(OBJDIR)
	$(NVCC) $(CXXFLAGS) -c $< -o $@

clean:
	rm -rf $(OBJDIR) $(BINDIR)

.PHONY: all clean