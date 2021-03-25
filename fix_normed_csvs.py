import shutil
import argparse
import glob


def fix_the_file(filename, folder):

    my_temp = folder + "my_test.csv"

    with open(filename) as f:
        with open(my_temp,'a') as writeto:
            first_line = f.readline()
            sample = first_line.split(',')[8].rstrip()
            sample = sample.split("_")[0]
            new_header = first_line.split(",")
            new_header[8] = 'psi'
            new_header.append('sample' + '\n')
            writeto.write(",".join(new_header))
            for i, line in enumerate(f):
                temp_line = line.split(",")
                temp_line[8] = temp_line[8].rstrip()
                temp_line.append(sample + '\n')
                writeto.write(",".join(temp_line))

    shutil.move(my_temp,filename)

    return(0)



if __name__ == '__main__':
    parser = argparse.ArgumentParser()

    parser.add_argument("-f","--folder", help="Folder with the files you want to fix")
    parser.add_argument("-g","--grep", help="A grep pattern for the files")

    args = parser.parse_args()

    folder = args.folder
    grep = args.grep

    fixy_files = glob.glob(folder + grep)

    for f in fixy_files:
        fix_the_file(f, folder)
