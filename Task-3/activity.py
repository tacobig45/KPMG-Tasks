
def pick(input_object, target_key):
    if type(input_object) is dict and input_object:
        for key in input_object:
            if key == target_key:
                print("{}: {}".format(target_key, input_object[key]))
            pick(input_object[key], target_key)

                

    elif type(input_object) is list and input_object:
        for item in input_object:
            pick(item, target_key)


            



