# mpirun --hostfile ~/hostfile --map-by ppr:1:node git -C /home/ec2-user/deps/msccl pull

############## install aws-ofi-nccl-1.7.4-aws without AWS optimization ##############

mpirun --hostfile ~/hostfile --map-by ppr:1:node mkdir /home/ec2-user/deps/aws-ofi-nccl-lyd-v1

mpirun --hostfile ~/hostfile --map-by ppr:1:node tar -xzvf /home/ec2-user/deps/aws-ofi-nccl-1.7.4-aws.tar.gz -C /home/ec2-user/deps/aws-ofi-nccl-lyd-v1

mpirun --hostfile ~/hostfile --map-by ppr:1:node /home/ec2-user/deps/aws-ofi-nccl-lyd-v1/aws-ofi-nccl-1.7.4-aws/configure \
    --prefix=/opt/aws-ofi-nccl-lyd-v1  \
    --enable-platform-aws=0 \
    --with-libfabric=/opt/amazon/efa \
    --with-cuda=/usr/local/cuda

mpirun --hostfile ~/hostfile --map-by ppr:1:node bash -c "cd /home/ec2-user/deps/aws-ofi-nccl-lyd-v1/aws-ofi-nccl-1.7.4-aws && make"

mpirun --hostfile ~/hostfile --map-by ppr:1:node bash -c "cd /home/ec2-user/deps/aws-ofi-nccl-lyd-v1/aws-ofi-nccl-1.7.4-aws && sudo make install"

mpirun --hostfile ~/hostfile --map-by ppr:1:node wget https://github.com/aws/aws-ofi-nccl/releases/download/v1.7.4-aws/aws-ofi-nccl-1.7.4-aws.tar.gz


mpirun --hostfile ~/hostfile --map-by ppr:1:node git -C /home/ec2-user/deps/msccl-tools-lyd pull

mpirun --hostfile ~/hostfile --map-by ppr:1:node git -C /home/ec2-user/deps clone https://github.com/NVIDIA/nccl.git

mpirun --hostfile ~/hostfile --map-by ppr:1:node mkdir /home/ec2-user/deps/aws-setup-lyd

mpirun --hostfile ~/hostfile --map-by ppr:1:node git -C /home/ec2-user/deps/aws-setup-lyd clone https://github.com/dailiuyao/aws-setup-lyd.git

mpirun --hostfile ~/hostfile --map-by ppr:1:node git -C /home/ec2-user/deps/aws-setup-lyd/aws-setup-lyd pull

mpirun --hostfile ~/hostfile --map-by ppr:1:node bash -c "sudo sh /home/ec2-user/deps/aws-setup-lyd/aws-setup-lyd/setup-nccl-lyd.sh"

mpirun --hostfile ~/hostfile --map-by ppr:1:node bash -c "sudo sh /home/ec2-user/deps/aws-setup-lyd/aws-setup-lyd/ccl-run.sh"

mpirun --hostfile ~/hostfile --map-by ppr:1:node bash -c "cd /home/ec2-user/deps/nccl && make -j src.build"

mpirun --hostfile ~/hostfile --map-by ppr:1:node bash -c "cd /home/ec2-user/deps/nccl && make src.build CUDA_HOME=/usr/local/cuda"

mpirun --hostfile ~/hostfile --map-by ppr:1:node bash -c "cd /home/ec2-user/deps/nccl && sudo make -j src.build CUDA_HOME=/usr/local/cuda"

make -j src.build

############## MSCCL TEST for non AWS optimization ##############

## Library Install Locations
- EFA: /opt/amazon/efa
- OpenMPI: /opt/amazon/openmpi
- CUDA: /usr/local/cuda
- NCCL: /opt/nccl/build
- cuDNN: /opt/cudnn
- cuSPARSE_lt: /opt/libcusparse_lt
- OpenBLAS: /opt/OpenBLAS
- Magma: /opt/magma

## Plugins, etc.
- AWS OFI NCCL Plugin: /opt/aws-ofi-nccl


mpirun --hostfile ~/hostfile --map-by ppr:8:node \
    -x CUDA_HOME="/usr/local/cuda" \
    -x CUDA_PATH="/usr/local/cuda" \
    -x NCCL_HOME="/home/ec2-user/deps/msccl/build" \
    -x MPI_HOME="/opt/amazon/openmpi" \
    -x LD_LIBRARY_PATH="/opt/aws-ofi-nccl-lyd-v1/lib:/opt/amazon/openmpi/lib64:/home/ec2-user/deps/msccl/build/lib:/usr/local/cuda/lib64:${LD_LIBRARY_PATH}" \
    -x NCCL_DEBUG="INFO" \
    -x FI_EFA_FORK_SAFE=1 \
    -x MSCCL_XML_FILES="/home/ec2-user/deps/msccl-tools-lyd/examples/xml/xml_lyd/aws-test/8nic/16gpus/allreduce_binary_tree_node2_gpu16_mcl8_mck16_gan0.xml" \
    -x GENMSCCLXML=1 \
    --mca btl tcp,self --mca btl_tcp_if_exclude lo,docker0 --bind-to none \
    /home/ec2-user/deps/nccl-tests-lyd/build/all_reduce_perf \
    --nthreads 1 \
    --ngpus 1 \
    --minbytes 512K \
    --maxbytes 256M \
    --stepfactor 2 \
    --op sum \
    --datatype float \
    --iters 20 \
    --warmup_iters 5



mpirun --hostfile ~/hostfile --map-by ppr:8:node \
    -x CUDA_HOME="/usr/local/cuda" \
    -x CUDA_PATH="/usr/local/cuda" \
    -x NCCL_HOME="/opt/nccl-lyd/build" \
    -x MPI_HOME="/opt/amazon/openmpi" \
    -x LD_LIBRARY_PATH="/opt/aws-ofi-nccl/lib:/opt/amazon/openmpi/lib64:/opt/nccl-lyd/build/lib:/usr/local/cuda/lib64:${LD_LIBRARY_PATH}" \
    -x NCCL_DEBUG="TRACE" \
    -x NCCL_ALGO="TREE" \
    -x FI_EFA_FORK_SAFE=1 \
    -x GENMSCCLXML=1 \
    --mca btl tcp,self --mca btl_tcp_if_exclude lo,docker0 --bind-to none \
    /home/ec2-user/deps/nccl-tests-lyd/build/all_reduce_perf \
    --nthreads 1 \
    --ngpus 1 \
    --minbytes 512K \
    --maxbytes 256M \
    --stepfactor 2 \
    --op sum \
    --datatype float \
    --iters 20 \
    --warmup_iters 5

############## MSCCL TEST for AWS optimization (only for trinomial tree) ##############

mpirun --hostfile ~/hostfile --map-by ppr:8:node \
    -x CUDA_HOME="/usr/local/cuda" \
    -x CUDA_PATH="/usr/local/cuda" \
    -x NCCL_HOME="/home/ec2-user/deps/msccl/build" \
    -x MPI_HOME="/opt/amazon/openmpi" \
    -x LD_LIBRARY_PATH="/opt/aws-ofi-nccl/lib:/opt/amazon/openmpi/lib64:/home/ec2-user/deps/msccl/build/lib:/usr/local/cuda/lib64:${LD_LIBRARY_PATH}" \
    -x NCCL_DEBUG="INFO" \
    -x FI_EFA_FORK_SAFE=1 \
    -x MSCCL_XML_FILES="/home/ec2-user/deps/msccl-tools-lyd/examples/xml/xml_lyd/aws-test/1nic/16gpus/allreduce_trinomial_tree_2ch_128chunk.xml" \
    -x GENMSCCLXML=1 \
    --mca btl tcp,self --mca btl_tcp_if_exclude lo,docker0 --bind-to none \
    /home/ec2-user/deps/nccl-tests-lyd/build/all_reduce_perf \
    --nthreads 1 \
    --ngpus 1 \
    --minbytes 768K \
    --maxbytes 384M \
    --stepfactor 2 \
    --op sum \
    --datatype float \
    --iters 20 \
    --warmup_iters 5 
    # > output.txt 2>&1

############################# Inter Node NCCL Experiments #############################

mpirun --hostfile ~/hostfile --map-by ppr:8:node \
    -x CUDA_HOME="/usr/local/cuda" \
    -x CUDA_PATH="/usr/local/cuda" \
    -x NCCL_HOME="/opt/nccl/build" \
    -x MPI_HOME="/opt/amazon/openmpi" \
    -x LD_LIBRARY_PATH="/opt/aws-ofi-nccl/lib:/opt/amazon/openmpi/lib64:/opt/nccl/build/lib:/usr/local/cuda/lib64:${LD_LIBRARY_PATH}" \
    -x NCCL_DEBUG="TRACE" \
    -x FI_EFA_FORK_SAFE=1 \
    -x NCCL_ALGO=TREE \
    -x GENMSCCLXML=1 \
    --mca btl tcp,self --mca btl_tcp_if_exclude lo,docker0 --bind-to none \
    /home/ec2-user/ly-custom/nccl-tests-lyd/build/all_reduce_perf \
    --nthreads 1 \
    --ngpus 1 \
    --minbytes 128K \
    --maxbytes 512M \
    --stepfactor 2 \
    --op sum \
    --datatype float \
    --iters 20 \
    --warmup_iters 5 \
    > output_nccl_sum_float_tree.log 2>&1

############################# Intra Node NCCL Experiments #############################

    mpirun -n 8 --oversubscribe \
    -x CUDA_HOME="/usr/local/cuda" \
    -x CUDA_PATH="/usr/local/cuda" \
    -x NCCL_HOME="/opt/nccl/build" \
    -x MPI_HOME="/opt/amazon/openmpi" \
    -x LD_LIBRARY_PATH="/opt/aws-ofi-nccl/lib:/opt/amazon/openmpi/lib64:/opt/nccl/build/lib:/usr/local/cuda/lib64:${LD_LIBRARY_PATH}" \
    -x NCCL_DEBUG="INFO" \
    -x FI_EFA_FORK_SAFE=1 \
    -x NCCL_ALGO=RING \
    -x GENMSCCLXML=1 \
    --mca btl tcp,self --mca btl_tcp_if_exclude lo,docker0 --bind-to none \
    /home/ec2-user/deps/nccl-tests-lyd/build/all_reduce_perf \
    --nthreads 1 \
    --ngpus 1 \
    --minbytes 128K \
    --maxbytes 512M \
    --stepfactor 2 \
    --op sum \
    --datatype float \
    --iters 20 \
    --warmup_iters 5 \
    > output_nccl_sum_float_ring_intra.log 2>&1

############################# Intra Node MSCCL Experiments #############################

    mpirun -n 8 --oversubscribe \
    -x CUDA_HOME="/usr/local/cuda" \
    -x CUDA_PATH="/usr/local/cuda" \
    -x NCCL_HOME="/home/ec2-user/deps/msccl/build" \
    -x MPI_HOME="/opt/amazon/openmpi" \
    -x LD_LIBRARY_PATH="/opt/aws-ofi-nccl/lib:/opt/amazon/openmpi/lib64:/home/ec2-user/deps/msccl/build/lib:/usr/local/cuda/lib64:${LD_LIBRARY_PATH}" \
    -x NCCL_DEBUG="INFO" \
    -x FI_EFA_FORK_SAFE=1 \
    -x GENMSCCLXML=1 \
    -x NCCL_ALGO="MSCCL,TREE,RING" \
    -x MSCCL_XML_FILES="/home/ec2-user/deps/msccl-tools-lyd/examples/xml/xml_lyd/aws-test/intra/allreduce_ring_8ch_4chunk.xml" \
    --mca btl tcp,self --mca btl_tcp_if_exclude lo,docker0 --bind-to none \
    /home/ec2-user/deps/nccl-tests-lyd/build/all_reduce_perf \
    --nthreads 1 \
    --ngpus 1 \
    --minbytes 128K \
    --maxbytes 512M \
    --stepfactor 2 \
    --op sum \
    --datatype float \
    --iters 20 \
    --warmup_iters 5 \
    >> output_nccl_sum_float_msccl_intra.log 2>&1

allreduce_binary_tree_2ch_256chunk
allreduce_binomial_tree_2ch_128chunk
allreduce_recursive_doubling_2ch_32chunk
allreduce_recursive_doubling_halving_2ch_32chunk
allreduce_ring_8ch_4chunk
allreduce_trinomial_tree_1ch_128chunk
allreduce_trinomial_tree_2ch_128chunk

# only for trinomial tree
    mpirun -n 8 --oversubscribe \
    -x CUDA_HOME="/usr/local/cuda" \
    -x CUDA_PATH="/usr/local/cuda" \
    -x NCCL_HOME="/home/ec2-user/deps/msccl/build" \
    -x MPI_HOME="/opt/amazon/openmpi" \
    -x LD_LIBRARY_PATH="/opt/aws-ofi-nccl/lib:/opt/amazon/openmpi/lib64:/home/ec2-user/deps/msccl/build/lib:/usr/local/cuda/lib64:${LD_LIBRARY_PATH}" \
    -x NCCL_DEBUG="INFO" \
    -x FI_EFA_FORK_SAFE=1 \
    -x GENMSCCLXML=1 \
    -x NCCL_ALGO="MSCCL,TREE,RING" \
    -x MSCCL_XML_FILES="/home/ec2-user/deps/msccl-tools-lyd/examples/xml/xml_lyd/aws-test/intra/allreduce_trinomial_tree_2ch_128chunk.xml" \
    --mca btl tcp,self --mca btl_tcp_if_exclude lo,docker0 --bind-to none \
    /home/ec2-user/deps/nccl-tests-lyd/build/all_reduce_perf \
    --nthreads 1 \
    --ngpus 1 \
    --minbytes 768K \
    --maxbytes 384M \
    --stepfactor 2 \
    --op sum \
    --datatype float \
    --iters 20 \
    --warmup_iters 5 \
    >> output_nccl_sum_float_msccl_intra.log 2>&1

############## notes for AllReduce experiments on AWS SC24 ###############
1. -x OFI_NCCL_NIC_DUP_CONNS=2

2. message size: 
      other algorithms: 128K - 512M 
      trinomial tree: 192K - 768M

3. number of channels and chunks:
      recursive_having_doubling
            nchunks_values=(8 16 32)
            nchannel_values=(1 2)    
      ring  
            nchunks_values=(1 2 4)
            nchannel_values=(2 4 8)  
      double_binary_tree
            nchunks_values=(8 16 32 64 128 256)
            nchannel_values=(1 2)    
      double_binomial_tree  
            nchunks_values=(8 16 32 64 128)
            nchannel_values=(1 2)
      triple_trinomial_tree 
            nchunks_values=(8 16 32 64 128)
            nchannel_values=(1 2)
      recursive_doubling
            nchunks_values=(8 16 32)
            nchannel_values=(1 2)

4. XML format:
            allreduce_recursive_doubling_halving_${nchannel}ch_${nchunks}chunk.xml
            allreduce_ring_${nchannel}ch_${nchunks}chunk.xml
            allreduce_binary_tree_${nchannel}ch_${nchunks}chunk.xml
            allreduce_binomial_tree_${nchannel}ch_${nchunks}chunk.xml
            allreduce_trinomial_tree_${nchannel}ch_${nchunks}chunk.xml
            allreduce_recursive_doubling_${nchannel}ch_${nchunks}chunk.xml

5. XML file path:
            home/ec2-user/deps/msccl-tools-lyd/examples/xml/xml_lyd/aws-test/1nic/16gpus/XXX.xml

6. nccl test for MSCCL path:
            /home/ec2-user/deps/nccl-tests-lyd/build/all_reduce_perf

7. MSCCL path:
            /home/ec2-user/deps/msccl/build




lspci -tvv


ssh ec2-user@3.129.153.226


# System Summary

## Library Install Locations
- EFA: /opt/amazon/efa
- OpenMPI: /opt/amazon/openmpi
- CUDA: /usr/local/cuda
- NCCL: /opt/nccl/build
- cuDNN: /opt/cudnn
- cuSPARSE_lt: /opt/libcusparse_lt
- OpenBLAS: /opt/OpenBLAS
- Magma: /opt/magma

## Plugins, etc.
- AWS OFI NCCL Plugin: /opt/aws-ofi-nccl

## Softwares and Binaries
- Ninja: /opt/ninja (just `bin` directory within this)

## Example of running NCCL Tests:
```bash
/opt/amazon/openmpi/bin/mpirun \
    -x FI_EFA_USE_DEVICE_RDMA=1 \
    -x LD_LIBRARY_PATH=/opt/nccl/build/lib:/usr/local/cuda/lib64:/opt/amazon/efa/lib64:/opt/amazon/openmpi/lib64:/opt/aws-ofi-nccl/lib:$LD_LIBRARY_PATH \
    -x NCCL_DEBUG=INFO \
    -n 8 -N 8 \
    --mca pml ^cm --mca btl tcp,self --mca btl_tcp_if_exclude lo,docker0 --bind-to none \
    $HOME/stock/nccl-tests/build/all_reduce_perf -b 8 -e 16G -f 2 -g 1 -c 1 -n 100




rsync --progress --stats -ruzath -e "ssh -i /home/liuyao/.ssh/id_rsa_vir" "ec2-user@18.223.104.188:/home/ec2-user/ly-custom/experiments_output" /home/liuyao/scratch/deps/aws-setup-lyd/results_64_H100