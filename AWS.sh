# mpirun --hostfile ~/hostfile --map-by ppr:1:node git -C /home/ec2-user/deps/msccl pull

############## install aws-ofi-nccl-1.7.4-aws without AWS optimization ##############

mpirun --hostfile ~/hostfile --map-by ppr:1:node mkdir /home/ec2-user/deps/aws-ofi-nccl-lyd-v1

mpirun --hostfile ~/hostfile --map-by ppr:1:node tar -xzvf /mnt/sharedfs/ly-experiments/aws-ofi-nccl-1.8.1-aws.tar.gz -C ./aws-ofi-nccl-lyd

mpirun --hostfile ~/hostfile --map-by ppr:1:node /home/ec2-user/deps/aws-ofi-nccl-lyd-v1/aws-ofi-nccl-1.7.4-aws/configure \
    --prefix=/mnt/sharedfs/ly-experiments/aws-ofi-nccl-lyd  \
    --enable-platform-aws=0 \
    --with-libfabric=/opt/amazon/efa \
    --with-cuda=/usr/local/cuda

./configure \
    --prefix=/mnt/sharedfs/ly-experiments/aws-ofi-nccl-lyd  \
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

# System Summary

## Persistent shared data store
# - /mnt/sharedfs (This should be mounted if you're running this instance in a cluster environment)

## Compiler Versions
- gcc 7.3.1 (Default): /usr/bin/gcc
- g++ 7.3.1 (Default): /usr/bin/g++ 
- gcc 10.5.0: /usr/bin/gcc10-gcc
- g++ 10.5.0: /usr/bin/gcc10-g++

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
```

##### MSCCL ######

mpirun --hostfile ~/hostfile --map-by ppr:8:node \
    -x CUDA_HOME="/usr/local/cuda" \
    -x CUDA_PATH="/usr/local/cuda" \
    -x NCCL_HOME="/mnt/sharedfs/ly-experiments/msccl-lyd/build" \
    -x MPI_HOME="/opt/amazon/openmpi" \
    -x LD_LIBRARY_PATH="/opt/aws-ofi-nccl/lib:/opt/amazon/openmpi/lib64:/mnt/sharedfs/ly-experiments/msccl-lyd/build/lib:/usr/local/cuda/lib64:${LD_LIBRARY_PATH}" \
    -x NCCL_DEBUG="TRACE" \
    -x FI_EFA_FORK_SAFE=1 \
    -x NCCL_P2P_NET_CHUNKSIZE=65536 \
    -x MSCCL_XML_FILES="/mnt/sharedfs/ly-experiments/msccl-tools-lyd/examples/xml/xml_lyd/aws-test/32nic/32gpus/allreduce_ring_node4_gpu32_mcl4_mck2_gan0.xml" \
    -x GENMSCCLXML=1 \
    --mca btl tcp,self --mca btl_tcp_if_exclude lo,docker0 --bind-to none \
    /mnt/sharedfs/ly-experiments/nccl-tests-lyd/build/all_reduce_perf \
    --nthreads 1 \
    --ngpus 1 \
    --minbytes 64K \
    --maxbytes 2G \
    --stepfactor 2 \
    --op sum \
    --datatype float \
    --iters 20 \
    --warmup_iters 5 \
    > allreduce_ring_node4_gpu32_mcl4_mck2_gan0.log 2>&1

/home/liuyao/scratch/deps/msccl_tools_lyd/examples/xml/xml_lyd/aws-test/32nic/32gpus/allreduce_ring_node4_gpu32_mcl4_mck2_gan0.xml


##### NCCL 2.12.12 ######

mpirun --hostfile ~/hostfile --map-by ppr:8:node \
    -x CUDA_HOME="/usr/local/cuda" \
    -x CUDA_PATH="/usr/local/cuda" \
    -x NCCL_HOME="/mnt/sharedfs/ly-experiments/nccl_2_12_12/build" \
    -x MPI_HOME="/opt/amazon/openmpi" \
    -x LD_LIBRARY_PATH="/opt/aws-ofi-nccl/lib:/opt/amazon/openmpi/lib64:/mnt/sharedfs/ly-experiments/nccl_2_12_12/build/lib:/usr/local/cuda/lib64:${LD_LIBRARY_PATH}" \
    -x NCCL_DEBUG="TRACE" \
    -x FI_EFA_FORK_SAFE=1 \
    -x NCCL_MIN_NCHANNELS=32 \
    -x NCCL_MAX_NCHANNELS=32 \
    -x NCCL_ALGO=RING \
    -x GENMSCCLXML=1 \
    --mca btl tcp,self --mca btl_tcp_if_exclude lo,docker0 --bind-to none \
    /mnt/sharedfs/ly-experiments/nccl-tests-lyd/build/all_reduce_perf \
    --nthreads 1 \
    --ngpus 1 \
    --minbytes 64K \
    --maxbytes 2G \
    --stepfactor 2 \
    --op sum \
    --datatype float \
    --iters 20 \
    --warmup_iters 5 \
    > output_nccl_2_12_12_sum_float_ring_ch32.log 2>&1

    /home/liuyao/scratch/deps/msccl_tools_lyd/examples/xml/xml_lyd/aws-test/8nic/64gpus/allreduce_binary-tree_node8_gpu64_mcl4_mck1_gan0.xml

##### NCCL ######

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
    /mnt/sharedfs/ly-experiments/nccl-tests-lyd/build/all_reduce_perf \
    --nthreads 1 \
    --ngpus 1 \
    --minbytes 64K \
    --maxbytes 2G \
    --stepfactor 2 \
    --op sum \
    --datatype float \
    --iters 20 \
    --warmup_iters 5 \
    > output_nccl_sum_float_tree_buff_2.log 2>&1


    -x NCCL_MIN_NCHANNELS=32 \
    -x NCCL_MAX_NCHANNELS=32 \

    /home/liuyao/scratch/deps/msccl_tools_lyd/examples/xml/xml_lyd/aws-test/8nic/64gpus/allreduce_binary-tree_node8_gpu64_mcl4_mck1_gan0.xml





##################################### PARAM TEST ####################################
 conda install pytorch pytorch-cuda=12.4 -c pytorch-nightly -c nvidia
mpirun --hostfile ~/hostfile --map-by ppr:8:node /home/ec2-user/deps/aws-ofi-nccl-lyd-v1/aws-ofi-nccl-1.7.4-aws/configure \

mpirun --hostfile ~/hostfile --map-by ppr:8:node ./param/train/comms/pt/comms.py --master-ip ${hosts[1]} --w 100 --n 300 --b 64K --e 2G --f 2 --z 1 --collective all_reduce 

mpirun -np <num-processes> ./comms.py \ 
--master-ip xxx.xx.x.x 
--b <begin-size> \ 
--e <end-size> \ 
--n <num-iters> \ 
--f <step-factor> \ 
--z <blocking/non-blocking> \ 
--collective <collective-to-test> \ 
--backend nccl \ 
--device cuda 




























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






./scripts/run-aws.sh 2>&1 | tee /mnt/sharedfs/ly-experiments/aws-setup-lyd/results_64_H100/experiments_output/full-log.$(date +%Y%m%d%H%M%S).log