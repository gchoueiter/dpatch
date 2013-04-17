hitlist=$1.input
rm -f $1.input
echo "clusterUrl" >> $hitlist
for i in {1..400}
do
    echo "http://cs.brown.edu/~gen/nn_patches/"$1"/cluster_imgs/cluster"$i"/" >> $hitlist
done
